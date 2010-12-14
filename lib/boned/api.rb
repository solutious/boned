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
      bone = Bone.new params[:token]
      bone[params[:key]]
    end
  end
  
  get "/:token/keys/?" do
    carefully do
      bone = Bone.new params[:token]
      list = bone.keys || []
      list.join $/
    end
  end
      
  get "/:token/?" do
    carefully do
      bone = Bone.new params[:token]
      # list of buckets, currently hardcoded to global
      bone.token?(params[:token]) ? 'global' : ''
    end
  end
  
  post "/register/:token/?" do
    carefully do
      token = Bone.register_token params[:token], request.body.read.strip # no leading/trail whitspace
      token.nil? ? generic_error : token
    end
  end
  
  post "/:token/key/:key/?" do
    carefully do
      bone = Bone.new params[:token]
      bone.set params[:key], request.body.read  # don't modify content in any way
    end
  end
  
  delete "/destroy/:token/?" do
    carefully do
      if Bone.token? params[:token]
        Bone.destroy_token params[:token]
      else
        generic_error
      end
    end
  end
  
end


class Boned::API::Stub < Boned::APIBase
  get '/' do
    content_type 'text/plain'
    "Do you want to get bones?"
  end
end

