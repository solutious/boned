require 'pp'

#     /get/bashrc?path=/Users/delano/&env=development&role=fe&token=1901484c41b8752d61863e323c743abe2c6e90f8841bbdfa789e1d70bc6f4899
#     /set/bashrc?value=1000&path=/Users/delano/&env=development&role=fe&token=1901484c41b8752d61863e323c743abe2c6e90f8841bbdfa789e1d70bc6f4899
#
class Boned::API::Service < Boned::API
  set :public => 'public/'
  set :views => 'views/'
  
  error do
    "Bad bone rising"
  end
  
  get '/' do
    'Throw me a fricken bone'
  end
  
  get '/rev/?' do
    Boned::VERSION.inspect
  end
  
  get '/get/:key/?' do
    carefully do
      assert_params :key
      assert_exists current_token, "No token"
      assert_sha256 current_token
      bone = Bone.get current_token, params[:key], params
      bone.value
    end
  end
  
  post '/set/:key/?' do
    carefully do
      assert_params :key, :value
      assert_exists current_token, "No token"
      assert_sha256 current_token
      bone = Bone.new current_token, params[:key], params[:value], params
      bone.save
    end
    params[:value]
  end
  
  delete "/del/:key/?" do
    carefully do
      assert_params :key
      assert_exists current_token, "No token"
      assert_sha256 current_token
      bone = Bone.del current_token, params[:key], params
      bone.value
    end
  end
  
  get '/keys/:key' do
    carefully do
      assert_params :key
      assert_exists current_token, "No token"
      assert_sha256 current_token
      keys = Bone.keys current_token, params[:key]
      keys.join($/)
    end
  end
  
  get '/keys/?' do
    carefully do
      assert_exists current_token, "No token"
      assert_sha256 current_token
      keys = Bone.keys current_token, '*'
      keys.join($/)
    end
  end
  
  #post '/set/:key/?' do
  #  carefully do
  #    assert_params :key
  #    assert_sha256 current_token
  #    #assert_exists current_token
  #    #key, filter, path = params.values_at :key, :filter, :path
  #    #Boned::Object.set current_token, key
  #    pp request
  #    pp env['rack.input'].read
  #  end
  #end
  
end


