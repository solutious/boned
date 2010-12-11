# Rackup - Bonery.com
# 2009-12-11

ENV['RACK_ENV'] ||= 'production'
ENV['APP_ROOT'] = ::File.expand_path(::File.join(::File.dirname(__FILE__)))
$:.unshift(::File.join(ENV['APP_ROOT'], 'lib'))

require 'sinatra'

require 'boned/api'

disable :run    # disable sinatra's auto-application starting

configure :production do
  Boned.debug = false
  
  map("/bone/#{Boned::APIVERSION}/")  { run Boned::API::Service      }
  
end

configure :development do
  use Rack::ShowExceptions
  
  require 'boned/api/debug'
  require 'boned/api/redis'
  
  map("/bone/#{Boned::APIVERSION}/")  { run Boned::API::Service      }
  map("/debug")                       { run Boned::API::Debug        }  
  map("/redis")                       { run Boned::API::RedisViewer  }

end
