
unless defined?(BONED_HOME)
  BONED_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..') )
end

local_libs = %w{bone}
local_libs.each { |dir| 
  a = File.join(BONED_HOME, '..', '..', 'opensource', dir, 'lib')
  $:.unshift a
}

require 'bone'

module Boned
  Bone.source = 'redis://root@localhost:8045'
  #Bone.debug = true
end



