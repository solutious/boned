# Rackup - Boned
# 2009-12-11

# bin/boned -e dev start

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



