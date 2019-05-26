module Miller
  module Collectable
    module ClassMethods
      def collectable(name, klass)
        singleton_class.define_method name do |&block|
          _set_collectable(name, klass, [])
          self._collectables[name] << Class.new(klass, &block)
        end
        _gen_accessor(name)
      end
  
      def named_collectable(col_name, klass)
        singleton_class.define_method col_name do |name, &block|
          _set_collectable(col_name, klass, {})
          self._collectables[col_name][name] = Class.new(klass, &block)
        end
        _gen_accessor(col_name)
      end
  
      def _set_collectable(name, klass, default)
        self._collectables ||= {}
        self._collectables[name] ||= default 
      end
  
      def _gen_accessor(name)
        singleton_class.define_method "#{name}_col" do
          self._collectables[name]
        end
        define_method "#{name}_col" do
          self.class._collectables[name]
        end
      end
      def _collectables
        @_collectables ||= { }
      end
    end
    module InstanceMethods
      def _collectables
        self.class._collectables
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end 