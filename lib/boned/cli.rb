require 'boned/server'
require 'pp'

class Boned::CLI < Drydock::Command
  attr_accessor :exit_code
  
  
  def start
    Boned.connect
    if Boned.service_available?('127.0.0.1', server_opts[:port])
      raise Boned::Server::ServerRunning, server_opts[:port]
    end
    Boned::Controllers::Controller.new(server_opts).start 
  end
  
  def stop
    Boned.connect(false)
    Boned.stop_redis 
    if not Boned.service_available?('127.0.0.1', server_opts[:port])
      raise Boned::Server::ServerNotRunning, server_opts[:port]
    end
    Boned::Controllers::Controller.new(server_opts).stop 
  end
  
  def stop_redis
    Boned.connect(false)
    Boned.stop_redis
  end
  
  def info
    require 'yaml'
    if Boned.service_available?('127.0.0.1', server_opts[:port])
      puts "boned is running on port #{server_opts[:port]}"
    else
      puts "No boned"
    end
    puts "Options:", server_opts.to_yaml if @global.verbose > 0
  end
  
  private
  
  def server_opts
    port = @global.port || Boned::Server::DEFAULT_PORT
    config = @global.rackup || File.join(BONED_HOME, "config.ru")
    @server_opts ||= {
      :chdir                => Dir.pwd,
      :environment          => @global.environment || 'development',
      :address              => '0.0.0.0',
      :port                 => port,
      :timeout              => 30,
      :log                  => "/tmp/boned-#{port}.log",
      :pid                  => "/tmp/boned-#{port}.pid",
      :max_conns            => Thin::Server::DEFAULT_MAXIMUM_CONNECTIONS,
      :max_persistent_conns => Thin::Server::DEFAULT_MAXIMUM_PERSISTENT_CONNECTIONS,
      :require              => [],
      :wait                 => Thin::Controllers::Cluster::DEFAULT_WAIT_TIME,
      :backend              => "Boned::Server",
      :rackup               => config,
      :daemonize            => @global.daemon || false
    }
  end
end