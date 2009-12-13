

module Boned
  class Model < Storable
    def self.key(*el)
      raise "#{self}: nil keypart: #{el.inspect}" if el.size != el.compact.size
      a = "v1::#{self}"
      a << ':' << el.join(':') unless el.empty?
      a
    end
    def self.redis
      Boned.redis
    end
    def self.primarykey(v=nil)
      unless v.nil?
        @primarykey = v
        class_eval do  
          def primarykey() send(self.class.primarykey) end
        end
      end
      @primarykey
    end
    def redis
      self.class.redis
    end
    def save
      redis.sadd(self.class.key(kind, :all), self.primarykey) &&
      redis.set(key(:created), self.time.to_i) &&
      redis.set(key(:object), to_json)
    end
  end
end

Boned.require_glob 'boned', 'models', '*.rb'
