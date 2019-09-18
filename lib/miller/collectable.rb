module Miller
  module Collectable
    class Setup
      attr_reader :method_name, :opts
      attr_accessor :callee_opts, :setup_block
      def initialize(method_name, *args)
        @method_name = method_name
        @opts = extract_options(args)
        @klass = args.first
      end

      def extract_options(input_args)
        if input_args.last.is_a? Hash
          input_args.pop
        else
          {}
        end
      end

      def acc_name
        opts[:acc_name] || "#{method_name}_acc".to_sym
      end

      def type
        callee_opts[:type]
      end

      def default_acc
        type == :named_collectable ? {} : []
      end

      def registry
        opts[:acc_class] ? opts[:acc_class].new : default_acc
      end

      def parent_class
        # TODO validate parent class is a Miller class
        @klass
      end

      def value(*args, &block)
        if setup_block
          if block
            proc { setup_block.call(block.call(*args)) }
          else
            proc { setup_block.call(*args) }
          end
        else
          raise ParentClassNotProvided.new(self) unless parent_class
          raise BlockNotProvided.new(self) unless block
          Class.new(parent_class, &block)
        end
      end
    end
    module ClassMethods
      def collectable(*args, &block)
        setup = Setup.new(*args).tap do |s| 
                  s.callee_opts = {type: __method__}
                  s.setup_block = block
                end
        _define_collectable(setup)
      end
  
      def named_collectable(*args, &block)
        setup = Setup.new(*args).tap do |s| 
                  s.callee_opts = {type: __method__}
                  s.setup_block = block
                end
        _define_collectable(setup)
      end
      
      def _define_collectable(setup)
        singleton_class.define_method setup.method_name do |*args, &block|
          _set_collectable(setup)
          if setup.type == :named_collectable
            name = args.shift
            raise InvalidNameError.new(setup) unless name
            self._collectables[setup.acc_name][name] = setup.value(*args, &block)
          else
            self._collectables[setup.acc_name] << setup.value(*args, &block)
          end
        end
        _gen_accessor(setup)
      end
      
      def _set_collectable(setup)
        self._collectables[setup.acc_name] ||= setup.registry
        self._collectable_setups << [setup.method_name, setup]
      end
  
      def _gen_accessor(setup)
        singleton_class.define_method setup.acc_name do
          self._collectables[setup.acc_name]
        end
        define_method setup.acc_name do
          # TODO make a more interesting getter
          # example: #users(:john) and if block executes runs the #call
          self.class._collectables[setup.acc_name]
        end
      end
      def _collectables
        @_collectables ||= { }
      end
      def _collectable_setups
        @_collectable_setups ||= []
      end

      # def initialize_callback(setup, e)
      #   if e.is_a?(Proc)
      #     e.call(self, {})
      #   else
      #     e.new(self, {})
      #   end
      # end
    end
    module InstanceMethods
      def _collectables
        self.class._collectables
      end
      def _collectable_setups
        self.class._collectable_setups
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end
require_relative './collectable/errors'
