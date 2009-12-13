# ruby -rubygems -Ilib try/10_bone_model.rb
require 'boned'
Boned.load_config 
Boned.connect
Boned.enable_debug

token = Digest::SHA256.hexdigest('1901484c41b8752d61863e323c743')
key = 'simple'

puts Bone.keys(token)

__END__
opts = { :env => 'dev', :region => 'us-east-1a', :num => '01', :role => 'fe', :path => Dir.pwd  }
bone = Bone.new token, key, rand(100000).to_i, opts
#puts "BONE: " << bone.inspect, $/
bone.save
#puts "KEYS: " << Bone.keys( token, key).inspect, $/

bone = Bone.get( token, key, opts)
puts "GET: " << bone.inspect, $/
puts bone.to_json
