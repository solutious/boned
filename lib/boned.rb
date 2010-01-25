require 'rack/auth/digest/md5'

require 'redis'
require 'redis/namespace'
require 'storable'
require 'attic'
require 'gibbler/aliases'
require 'sysinfo'
require 'socket'
require 'uri'
require 'rye'

unless defined?(BONED_HOME)
  BONED_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..') )
end

module Boned  
  unless defined?(APIVERSION)
    APIVERSION = 'v1'.freeze 
    BONED_REDIS = "redis://127.0.0.1:8045/1".freeze
  end
  
  module VERSION
    MAJOR = 0
    MINOR = 2
    TINY  = 3
    PATCH = '001'
    def self.inspect; [to_s, PATCH].join('.'); end
    def self.to_s; [MAJOR, MINOR, TINY].join('.'); end
    def self.to_f; self.to_s.to_f; end
    def self.patch; PATCH; end
  end
  
  class Problem < RuntimeError; end
  class BadBone < Problem
    def message() "No such bone: #{super}" end
  end
  
  @debug = false
  @conf  = nil
  @redis = nil
  @redis_thread = nil
  @sysinfo = nil
  class << self
    attr_accessor :debug
    attr_reader :conf
    def debug?() @debug == true end
    def enable_debug() @debug = true end
    def disable_debug() @debug = false end
    def sysinfo
      @sysinfo = SysInfo.new.freeze if @sysinfo.nil?
      @sysinfo 
    end
    def redis() 
      @redis || Boned.connect
    end
  end
    
  # Connect to Redis and Mongo. 
  def self.connect(start_redis=true)
    update_redis_client_config
    ld "CONNECT: start_redis(#{start_redis})"
    if start_redis 
      self.start_redis
      abort "No Redis" unless redis_available?
    end
    @redis = Redis.new @conf[:redis]
  end
  
  def self.start_redis
    return if redis_available? 
    conf_path = File.join(BONED_HOME, 'config', 'redis-server.conf')
    ld "REDIS SERVER CONF: #{conf_path}"
    @redis_thread = Thread.new do
      Rye.shell 'redis-server', conf_path
    end
    sleep 2  # Give redis time to start. 
  end
  
  def self.stop_redis
    ld "SHUTDOWN REDIS #{redis_available?}"
    ld @redis.inspect
    # Shutdown command returns "-ERR operation not permitted" ??
    @redis.shutdown if !@redis.nil?  && redis_available? rescue nil
    return if @redis_thread.nil? || !@redis_thread.alive?
  end
  
  # <tt>require</tt> a library from the vendor directory.
  # The vendor directory should be organized such
  # that +name+ and +version+ can be used to create
  # the path to the library. 
  #
  # e.g.
  # 
  #     vendor/httpclient-2.1.5.2/httpclient
  #
  def self.require_vendor(name, version)
    path = File.join(BONED_HOME, 'vendor', "#{name}-#{version}", 'lib')
    $:.unshift path
    Boned.ld "REQUIRE VENDOR: ", path
    require name
  end
  
  def self.require_glob(*path)
    path = [BONED_HOME, 'lib', path].flatten
    libs = Dir.glob(File.join(*path))
    Boned.ld "REQUIRE GLOB: ", libs
    libs.each do |lib|
      next if lib == __FILE__
      require lib if File.file? lib
    end
  end
  
  # Checks whether something is listening to a socket. 
  # * +host+ A hostname
  # * +port+ The port to check
  # * +wait+ The number of seconds to wait for before timing out. 
  #
  # Returns true if +host+ allows a socket connection on +port+. 
  # Returns false if one of the following exceptions is raised:
  # Errno::EAFNOSUPPORT, Errno::ECONNREFUSED, SocketError, Timeout::Error
  #
  def self.service_available?(host, port, wait=3)
    a = Socket.getaddrinfo @conf[:redis][:host], @conf[:redis][:port]
    ip_addr = a[0][3]
    ld "SERVICE: #{host} (#{ip_addr}) #{port}"
    if Boned.sysinfo.vm == :java
      begin
        iadd = Java::InetSocketAddress.new host, port      
        socket = Java::Socket.new
        socket.connect iadd, wait * 1000  # milliseconds
        success = !socket.isClosed && socket.isConnected
      rescue NativeException => ex
        puts ex.message, ex.backtrace if Boned.debug?
        false
      end
    else 
      begin
        status = Timeout::timeout(wait) do
          socket = Socket.new( Socket::AF_INET, Socket::SOCK_STREAM, 0 )
          sockaddr = Socket.pack_sockaddr_in( port, host )
          socket.connect( sockaddr )
        end
        true
      rescue Errno::EAFNOSUPPORT, Errno::ECONNREFUSED, SocketError, Timeout::Error => ex
        puts ex.class, ex.message, ex.backtrace if Boned.debug?
        false
      end
    end
  end
  
  def self.redis_available?
    service_available? @conf[:redis][:host], @conf[:redis][:port]
  end
  
  def self.update_redis_client_config(uri=nil)
    uri ||= ENV['BONED_REDIS'] || BONED_REDIS
    uri = URI.parse(uri)
    @conf ||= {}
    @conf[:redis] = {
      :host => uri.host,
      :port => uri.port || 8045,
      :database => uri.path.sub(/\D/, "").to_i || 1,
      :password => uri.user || nil
    }
    ld "REDIS: #{@conf[:redis].inspect}"
  end
  
  def self.ld(*msg)
    return unless Boned.debug
    prefix = "D(#{Thread.current.object_id}):  "
    puts "#{prefix}" << msg.join("#{$/}#{prefix}")
  end
  
  update_redis_client_config  # parse ENV['BONED_REDIS']
end

require 'boned/models'