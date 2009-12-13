

usecase "Set" do
  set :key    => :simple
  set :token    => '1901484c41b8752d61863e323c743abe2c6e90f8841bbdfa789e1d70bc6f4899'
  
  get "/v1/set/:key" do
    set :value => (rand*100000).to_i
    param :token    => resource(:token)
    param :value  => resource(:value)
  end
  
  get "/v1/get/:key" do
    param :token    => resource(:token)
    response 200 do
      p [resource(:value), body.to_i]
    end
  end
  
  get "/v1/set/:key" do
    param :key => rand(1000).to_i
    set :value => (rand*100000).to_i
    param :token    => resource(:token)
    param :value  => resource(:value)
  end
  
  xpost "/v1/set/:key" do
    param :key    => :file
    body file('/tmp/file')
  end
  
end