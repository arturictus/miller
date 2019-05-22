module Miller
  class Collectable
    def self.data
      @data ||= { }
    end

    def data
      self.class.data
    end

    def self.collectable(name, klass)
      singleton_class.define_method name do |&block|
        self.data ||= {}
        self.data[name] ||= [] 
        self.data[name] << Class.new(klass, &block)
      end
    end

    def self.named_collectable(col_name, klass)
      singleton_class.define_method col_name do |name, &block|
        self.data ||= {}
        self.data[col_name] ||= {}
        self.data[col_name][name] = Class.new(klass, &block)
      end
    end
  end
end 