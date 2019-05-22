module Miller
  class Collectable
    def self._collectables
      @_collectables ||= { }
    end

    def _collectables
      self.class._collectables
    end

    def self.collectable(name, klass)
      singleton_class.define_method name do |&block|
        _set_collectable(name, klass, [])
        self._collectables[name] << Class.new(klass, &block)
      end
      _gen_accessor(name)
    end

    def self.named_collectable(col_name, klass)
      singleton_class.define_method col_name do |name, &block|
        _set_collectable(col_name, klass, {})
        self._collectables[col_name][name] = Class.new(klass, &block)
      end
      _gen_accessor(col_name)
    end

    def self._set_collectable(name, klass, default)
      self._collectables ||= {}
      self._collectables[name] ||= default 
    end

    def self._gen_accessor(name)
      singleton_class.define_method "#{name}_col" do
        self._collectables[name]
      end
      define_method "#{name}_col" do
        self.class._collectables[name]
      end
    end

  end
end 