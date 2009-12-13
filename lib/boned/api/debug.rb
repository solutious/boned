
class Boned::API::Debug < Boned::API
  set :public => 'public/debug/'
  set :views => 'views/debug/'
  
  not_found do
    'not found'
  end
  
  get '/env/?' do
    content_type 'text/plain'
    env.to_yaml
  end
  
  get '/slideshow' do
    content_type 'text/html'
    erb :slideshow
  end
end


