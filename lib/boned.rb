require 'rack/auth/digest/md5'

require 'redis'
require 'redis/namespace'
require 'storable'
require 'attic'
require 'gibbler/aliases'
require 'sysinfo'
require 'socket'

unless defined?(BONED_HOME)
  BONED_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..') )
end

module Boned
  APIVERSION = 'v1'.freeze unless defined?(APIVERSION)
  module VERSION
    MAJOR = 0
    MINOR = 2
    TINY  = 0
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
  @sysinfo = nil
  class << self
    attr_accessor :debug
    attr_reader :conf
    attr_accessor :redis
    def debug?() @debug == true end
    def enable_debug() @debug = true end
    def disable_debug() @debug = false end
    def sysinfo
      @sysinfo = SysInfo.new.freeze if @sysinfo.nil?
      @sysinfo 
    end
  end
  
  # Connect to Redis and Mongo. 
  def self.connect(conf=@conf)
    @redis = Redis.new conf[:redis]
  end
  
  # Loads the yaml config files from config/
  # * +base+ path where config dir lives
  # * +env one of: :development, :production
  # Returns a Hash: conf[:mongo][:host], ...
  def self.load_config(base=BONED_HOME, env=:development)
    @conf = {}                       
    [:redis].each do |n|
      Boned.ld "LOADING CONFIG: #{n}"
      tmp = YAML.load_file(File.join(base, "config", "#{n}.yml"))
      @conf[n] = tmp[ env.to_sym ]
    end
    @conf
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
  
  
  def self.ld(*msg)
    return unless Boned.debug
    prefix = "D(#{Thread.current.object_id}):  "
    puts "#{prefix}" << msg.join("#{$/}#{prefix}")
  end
  
end

require 'boned/models'