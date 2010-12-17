# Rackup - Boned
# 2009-12-11

# thin -p 3073 -P /tmp/bonery_delano.pid --rackup app.ru -e dev -l /tmp/bonery_delano.log start

ENV['RACK_ENV'] ||= 'production'
ENV['APP_ROOT'] = ::File.expand_path(::File.join(::File.dirname(__FILE__)))
$:.unshift(::File.join(ENV['APP_ROOT'], 'app'))
$:.unshift(::File.join(ENV['APP_ROOT'], 'lib'))

require 'sinatra'

require 'boned/api'

disable :run    # disable sinatra's auto-application starting

configure :prod, :proto, :status do
  Bone.info "arrested #{ENV['RACK_ENV']}"
  Bone.debug = false
  set :show_exceptions, false
  set :dump_errors, false
  set :reload_templates, false
  map("/#{Bone::APIVERSION}")         { run Boned::API       }
end

configure :dev do
  Bone.info "arrested #{ENV['RACK_ENV']}"    
  Bone.debug = true
  set :show_exceptions, true
  set :dump_errors, true
  set :reload_templates, true
  map("/#{Bone::APIVERSION}")         { run Boned::API       }
end



