require 'sinatra/reloader'  # consider big_band

class Boned::APIBase < Sinatra::Base
  
  set :public => 'public/'
  set :views => 'views/'
  set :static => true
  
  configure :dev do
    Bone.info "Environment: #{ENV['RACK_ENV']}"
    register Sinatra::Reloader
    dont_reload "lib/**/*.rb"
    also_reload "lib/boned.rb"
    before do
      #Bone.debug = true
      Bone.info $/, $/, "--> #{request_method} #{current_uri_path}"
      content_type 'text/plain'
      Boned.allow_register = true
    end
  end
  
  configure :prod do
    Bone.debug = false
    before do
      content_type 'application/json'
      Boned.allow_register = false
    end
  end
  
  helpers do
    def carefully(ret='', &blk)
      begin
        ret = blk.call
      rescue => ex
        generic_error ex.class, ex
      end
      ret
    end 
    
    def generic_error(event=nil, ex=nil)
      Bone.info "#{event} #{request_token}:#{request_signature}" unless event.nil?
      unless ex.nil?
        Bone.info ex.message
        Bone.ld ex.backtrace 
      end
      return error(404, "Bad bone rising")
    end
    
    def error_message msg
      Bone.info "[400] #{msg}"
      return error(400, msg)
    end
    
    def request_token
      env['HTTP_X_BONE_TOKEN'] || params[:token] 
    end
    def request_signature
      @request_signature ||= params[:sig] || env['HTTP_X_BONE_SIGNATURE']
      @request_signature
    end
    def request_secret
      # no leading/trail whitspace end
      @request_secret ||= (body_content || env['HTTP_X_BONE_SECRET']).strip 
      @request_secret
    end
    def body_content
      @body_content ||= request.body.read 
      @body_content
    end
    
    def uri(*path)
      [root_path, path].flatten.join('/')
    end
    def root_path
      env['SCRIPT_NAME']
    end
    def current_uri_path
      env['REQUEST_URI']
    end
    def request_method
      env['REQUEST_METHOD'].to_s.downcase  # important to be downcase for signature check
    end
    def current_host
      env['HTTP_HOST'].to_s.downcase
    end
    def secure?
      (env['HTTP_X_SCHEME'] == "https")  # X-Scheme is set by nginx
    end
    
    def local?
      LOCAL_HOSTS.member?(env['SERVER_NAME']) && (client_ipaddress == '127.0.0.1')
    end
    
    def assert_token
      assert_exists request_token, "No token"
    end
    
    def assert_secret
      assert_exists request_secret, "No secret"
    end
    
    def check_token
      generic_error "[unknown-token]" if !Bone.token? request_token
      true
    end
    
    def check_signature
      assert_exists request_signature, "No signature"
      assert_true params[:sigversion] == Bone::API::HTTP::SIGVERSION, "Bad API version: #{params[:sigversion]}"
      tobj = Bone::API::Redis::Token.new request_token
      secret = tobj.secret.value
      path = current_uri_path.split('?').first
      # We need to re-parse the query string b/c Sinatra or Rack is
      # including the value of the POST body as a key with no value.
      qs = Bone::API::HTTP.parse_query request.query_string
      qs.delete 'sig' # Yo dawg, I put a signature in your signature
      sig = Bone::API::HTTP.generate_signature secret, current_host, request_method, path, qs, body_content
      generic_error "[sig-mismatch] #{sig}" if sig != request_signature
      Bone.new request_token
    end

    
    # +names+ One or more a required parameter names (Symbol)
    def assert_params(*names)
      names.each do |n|
        return error_message("Missing param: %s" % n) if params[n].to_s.empty?
      end
      true
    end
    alias_method :assert_param, :assert_params
    
    def assert_exists(val, msg)
      return error_message msg if val.to_s.empty?
      true
    end
    
    def assert_true(val, msg)
      return error_message msg if val != true
      true
    end
    
    def assert_sha1(val)
      return error_message("#{val} is not a sha1 digest") unless is_sha1?(val)
    end
    
    def assert_sha256(val)
      return error_message("#{val} is not a sha256 digest") unless is_sha256?(val)
    end
    
    def is_sha1?(val)
      val.to_s.match(/\A[0-9a-f]{40}\z/)
    end
    def is_sha256?(val)
      val.to_s.match(/\A[0-9a-f]{64}\z/)
    end
    
  end
end

