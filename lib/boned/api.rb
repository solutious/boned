require 'boned'
require 'boned/api/base'

class Boned::API < Boned::APIBase

  # TODO: Remove these.
  get '/all' do
    keys = Bone::API::Redis::Token.redis.keys '*'
    keys.join $/
  end  
  get "/:token/secret/?" do
    carefully do
      assert_token && check_token
      bone = check_signature
      bone.secret
    end
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
      assert_token && check_token
      bone = check_signature
      bone.key?(params[:key]) ? bone[params[:key]] : generic_error
    end
  end
  
  get "/:token/keys/?" do
    carefully do
      assert_token && check_token
      bone = check_signature
      list = bone.keys || []
      list.join $/
    end
  end
  
  get "/:token/?" do
    carefully do
      assert_token && check_token
      bone = check_signature
      # list of buckets, currently hardcoded to global
      bone.token?(request_token) ? 'global' : generic_error
    end
  end
  
  post "/:token/key/:key/?" do
    carefully do
      assert_token && check_token
      bone = check_signature
      value = request.body.read # don't modify content in any way
      bone.set params[:key], value
    end
  end
  
  delete "/destroy/:token/?" do
    carefully do
      assert_token && check_token
      bone = check_signature
      Bone.destroy request_token
    end
  end
  
  post "/generate/?" do
    carefully do
      token, secret = *Bone.generate
      token.nil? ? generic_error : [token, secret].join($/)
    end
  end
  
  post "/register/:token/?" do
    carefully do
      generic_error '[register-disabled]' unless Boned.allow_register
      assert_secret
      generic_error "[rereg-attempt]" if Bone.token? request_token
      token = Bone.register request_token, request_secret
      token.nil? ? generic_error("[register-failed]") : token
    end
  end
  
  helpers do
    #Bone.debug = true
  end
end


class Boned::API::Stub < Boned::APIBase
  get '/' do
    content_type 'text/plain'
    "Do you want to get bones?"
  end
end

