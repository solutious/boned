require 'boned'
require 'boned/api/base'

class Boned::API < Boned::APIBase

  get '/all' do
    keys = Bone::API::Redis::Token.redis.keys '*'
    keys.join $/
  end
    
  #get "/:token/:bucket/keys/?" do
  #  Bone.info 
  #  "poop"
  #end
  #
  #get "/:token/:bucket/key/:key/?" do
  #  Bone.info 
  #  "poop"
  #end
  
  get "/:token/key/:key/?" do
    carefully do
      assert_token
      check_signature
      bone = Bone.new request_token
      bone.key?(params[:key]) ? bone[params[:key]] : generic_error
    end
  end
  
  get "/:token/keys/?" do
    carefully do
      assert_token
      check_signature
      bone = Bone.new request_token
      list = bone.keys || []
      list.join $/
    end
  end
      
  get "/:token/?" do
    carefully do
      assert_token
      check_signature
      bone = Bone.new request_token
      # list of buckets, currently hardcoded to global
      bone.token?(request_token) ? 'global' : generic_error
    end
  end
  
  post "/generate/?" do
    carefully do
      secret = request.body.read.strip # no leading/trail whitspace
      token = Bone.generate_token secret
      token.nil? ? generic_error : token
    end
  end
  
  post "/:token/key/:key/?" do
    carefully do
      assert_token
      check_signature
      bone = Bone.new request_token
      value = request.body.read # don't modify content in any way
      bone.set params[:key], value
    end
  end
  
  post "/register/:token/?" do
    carefully do
      assert_secret
      generic_error "[rereg-attempt]" if Bone.token? request_token
      token = Bone.register_token request_token, request_secret
      token.nil? ? generic_error("[register-failed]") : token
    end
  end
  
  delete "/destroy/:token/?" do
    carefully do
      assert_token && check_token
      check_signature
      Bone.destroy_token request_token
    end
  end
  
  helpers do
    def check_token
      generic_error "[unknown-token]" if !Bone.token? request_token
      true
    end
  end
end


class Boned::API::Stub < Boned::APIBase
  get '/' do
    content_type 'text/plain'
    "Do you want to get bones?"
  end
end

