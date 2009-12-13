

class Boned::API::RedisViewer < Boned::API

  set :public => 'public/'
  set :views => 'views/redisviewer/'
  
  before do
    content_type 'text/html' 
  end
  
  get '/list/:name' do
    Boned.redis.lrange(params[:name], 0, -1).to_yaml
  end
  
  get '/smembers/:name' do
    Boned.redis.smembers(params[:name]).to_yaml
  end
  
  get '/opts' do
    Boned.redis_opts.to_yaml
  end

  get '/get/:name' do
    '%s=%s' % [params[:name], Boned.redis.get(params[:name])]
  end
  
  get '/:key' do
    @keys = Boned.redis.keys("*#{params[:key]}*")
    erb :keys
  end
  
  get '/?' do
    @keys = Boned.redis.keys("*")
    erb :keys
  end
  
  
  helpers do
    def key_kind(key)
      Boned.redis.type key
    end
  end
end
