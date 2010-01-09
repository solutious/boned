
# Bone:a462b9ebda71f16cb1567ba8704695ae8dba9999:simple 
# Bone:a462b9ebda71f16cb1567ba8704695ae8dba9999:us-east-1a-dev-fe:simple
# Bone:a462b9ebda71f16cb1567ba8704695ae8dba9999:dev-fe:simple
# Bone:a462b9ebda71f16cb1567ba8704695ae8dba9999:us-east-1a:simple

class Bone < Boned::Model
  
  primarykey :boneid
  
  field :token
  field :name
  field :value
  field :prop
  
  def initialize(token, name, value, prop={})
    @prop ||= {}
    prop ||= {}
    prop.each_pair { |n,v| @prop[n.to_sym] ||= v }
    @token, @name = token, name
    @new = refresh!.nil?
    @value = value unless value.nil? # use the new value if provided
    @prop[:created] = Time.now.utc.to_i if new? || @prop[:created].nil?
    # resolve string/symbol ambiguity for properties
    def @prop.[](k) super(k.to_s.to_sym) || super(k.to_s) end
    def @prop.[]=(k,v) super(k.to_s.to_sym,v) end
  end
  
  def [](k) 
    self.respond_to?(k) ? self.send : self.prop[k]
  end
  
  def new?() @new == true end
    
  def file?
    !prop[:file].nil?
  end
  
  def region() prop[:region] end
  def env() prop[:env] end
  def role() prop[:role] end
  def num() prop[:num] end
  def path() prop[:path] end
    
  def boneid
    loc = [region, env, role, num].compact.join('-')
    parts = loc.empty? ? [token] : [token, loc]
    parts << path.gsub(/\A\//, '').tr('/', '-') unless path.nil? # TODO: support windows
    parts << name
    parts.collect { |p| p.to_s.tr(':', '-') }.join(':')
  end
  
  def key(*parts)
    parts.unshift boneid
    self.class.key *parts
  end
  
  def save
    redis.set(key, value)
    prop[:modified] = Time.now.utc.to_i
    redis.set(key(:prop), prop.to_json)
  end
  
  def refresh!
    Boned.ld "REFRESH: #{key}"
    @value = redis.get key
    prop = redis.get key(:prop)
    prop &&= JSON.parse(prop) rescue {}
    # Merge the stored props with the current ones. Enforce symbols!
    prop.each_pair { |n,v| @prop[n.to_sym] ||= v }
    Boned.ld " -> #{@value} #{@prop.inspect}"
    self
  rescue
    nil
  end
  
  def destroy!
    Boned.ld "DESTROY: #{key}"
    redis.del key
    redis.del key(:prop)
  end
  
  class << self
    
    def del(token, name, opts={})
      bone = get(token, name, opts)
      bone.destroy!
      bone
    end
    
    def get(token, name, opts={})
      bone = Bone.new token, name, nil, opts
      raise Boned::BadBone, bone.name if bone.value.nil?
      bone
    end
    
    def keys(token, k=nil, opts={})
      search = key(token) << '*'
      search << k unless k.nil?
      Boned.ld "SEARCHING: #{search}"
      dirty = redis.keys search  # contains :prop when no keyname specified
      clean = []
      dirty.each { |k| 
        next if k.match(/prop\z/); 
        clean << k.split(':')[4..-1].join(':') 
      }
      clean
    end
    
  end
  
end
