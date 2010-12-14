require 'sinatra/reloader'  # consider big_band

class Boned::APIBase < Sinatra::Base
  
  set :public => 'public/'
  set :views => 'views/'
  set :static => true
  
  configure :dev do
    Bone.info "Environment: #{ENV['RACK_ENV']}"
    register Sinatra::Reloader
    dont_reload "lib/**/*.rb"
    also_reload "lib/api/*.rb"
    also_reload "lib/api.rb"
    before do
      #Bone.debug = true
      Bone.info "#{request_method} #{current_uri_path} (#{params.inspect})"
      content_type 'text/plain'
    end
  end
  
  configure :prod do
    Bone.debug = false
    before do
      content_type 'application/json'
    end
  end
  
  helpers do
    def carefully(ret='', &blk)
      begin
        ret = blk.call
      #rescue Boned::BadBone => ex
      #  return error(404, ex.message)
      rescue => ex
        Boned.ld "#{current_token}:#{params[:key]}", ex.message
        Boned.ld ex.backtrace
        return error(400, "Bad bone rising")
      end
      ret
    end 
    
    def generic_error
      return error(404, "Unknown resource")
    end
    
    def current_token() @env['HTTP_X_BONE_TOKEN'] || params[:token] end
    def current_sig() @env['HTTP_X_BONE_SIGNATURE'] || params[:sig] end
  
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
      env['REQUEST_METHOD']
    end
    
    def secure?
      (env['HTTP_X_SCHEME'] == "https")  # X-Scheme is set by nginx
    end
    
    def local?
      LOCAL_HOSTS.member?(env['SERVER_NAME']) && (client_ipaddress == '127.0.0.1')
    end
    
    # +names+ One or more a required parameter names (Symbol)
    def assert_params(*names)
      names.each do |n|
        if params[n].nil? || params[n].empty?
          return error(400, "Missing param: %s" % n)
        end
      end
    end
    alias_method :assert_param, :assert_params

    def assert_exists(val, msg)
      return error(400, msg) if val.nil? || val.to_s.empty?
    end

    def assert_true(val, msg)
      return error(400, msg) if val == true
    end
    
    def assert_sha1(val)
      return error(400, "#{val} is not a sha1 digest") unless is_sha1?(val)
    end
    
    def assert_sha256(val)
      return error(400, "#{val} is not a sha256 digest") unless is_sha256?(val)
    end
    
    def is_sha1?(val)
      val.to_s.match(/\A[0-9a-f]{40}\z/)
    end
    def is_sha256?(val)
      val.to_s.match(/\A[0-9a-f]{64}\z/)
    end
    
  end
end

