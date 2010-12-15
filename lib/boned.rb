
unless defined?(BONED_HOME)
  BONED_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..') )
end

local_libs = %w{bone}
local_libs.each { |dir| 
  a = File.join(BONED_HOME, '..', '..', 'opensource', dir, 'lib')
  $:.unshift a
}

module Boned
  module VERSION
    def self.to_s
      load_config
      [@version[:MAJOR], @version[:MINOR], @version[:PATCH]].join('.')
    end
    alias_method :inspect, :to_s
    def self.load_config
      require 'yaml'
      @version ||= YAML.load_file(File.join(BONED_HOME, '..', 'VERSION.yml'))
    end
  end
end


require 'bone'

Bone.source = 'redis://localhost:8045'
Bone.debug = false

module Boned
  @allow_register = false
  class << self
    attr_reader :allow_register
    # Disabled the API method for regsitering given tokens.
    # The value is automatically frozen so it will only
    # work once per instance of Ruby.
    def allow_register= v
      @allow_register = v.freeze unless @allow_register.frozen?
    end
  end
end



