module Miller
  module Collectable
    class Setup
      attr_accessor :method_name, :klass, :opts
      def initialize(method_name, opts)
        @method_name = method_name
        @klass = opts[:parent]
        @opts = opts
      end

      def acc_name
        opts[:acc_name] || "#{method_name}_acc".to_sym
      end
    end
    module ClassMethods
      def collectable(method_name, opts = {})
        setup = Setup.new(method_name, opts)
        singleton_class.define_method setup.method_name do |&block|
          _set_collectable(setup.acc_name, setup.klass, [])
          self._collectables[setup.acc_name] << if block_given?
                                                  yield(block.call)
                                                else
                                                  Class.new(setup.klass, &block)
                                                end
        end
        _gen_accessor(setup)
      end
  
      def named_collectable(method_name, opts = {})
        setup = Setup.new(method_name, opts)
        singleton_class.define_method setup.method_name do |name, &block|
          _set_collectable(setup.acc_name, setup.klass, {})
          self._collectables[setup.acc_name][name] = Class.new(setup.klass, &block)
        end
        _gen_accessor(setup)
      end
  
      def _set_collectable(name, klass, default)
        self._collectables ||= {}
        self._collectables[name] ||= default 
      end
  
      def _gen_accessor(setup)
        singleton_class.define_method setup.acc_name do
          self._collectables[setup.acc_name]
        end
        define_method setup.acc_name do
          self.class._collectables[setup.acc_name]
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
