require 'thin'
require 'logging'
require 'forwardable'

module Boned
  class Server < Thin::Backends::Base
    DEFAULT_PORT = 6043.freeze
    
    class ServerRunning < Boned::Problem
      def message() "Server already running on port: #{super}" end
    end
    
    class ServerNotRunning < Boned::Problem
      def message() "Server not running on port: #{super}" end
    end
    
    class << self
    end
    
    # Address and port on which the server is listening for connections.
    attr_accessor :host, :port
    
    def initialize(host, port, options)
      @host = host
      @port = port
      super()
    end

    # Connect the server
    def connect
      @signature = EventMachine.start_server(@host, @port, Thin::Connection, &method(:initialize_connection))
    rescue => ex
      puts ex.message
      puts ex.backtrace if Boned.debug
      stop!
    end

    # Stops the server
    def disconnect
      EventMachine.stop_server(@signature)
    end
    
    def to_s
      "#{@host}:#{@port}"
    end
    
  end
  module Controllers
    class Controller < Thin::Controllers::Controller
    end
    class Service < Thin::Controllers::Service
    end
    class Cluster < Thin::Controllers::Cluster
    end
  end
end




#controller = case
#when cluster? then Thin::Controllers::Cluster.new(options)
#when service? then Thin::Controllers::Service.new(options)
#else               Thin::Controllers::Controller.new(options)
#end


