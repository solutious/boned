
unless defined?(BONED_HOME)
  BONED_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..') )
end

local_libs = %w{bone}
local_libs.each { |dir| 
  a = File.join(BONED_HOME, '..', '..', 'opensource', dir, 'lib')
  $:.unshift a
}

class Boned
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

module Boned
  Bone.source = 'redis://root@localhost:6379'
  #Bone.debug = true
end



