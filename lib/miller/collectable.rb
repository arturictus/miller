module Miller
  module Collectable
    class Error < StandardError
      def initialize(setup)
        @setup = setup
        super(_gen_message)
      end

      def _gen_message
        raise NotImplementedError
      end
    end
    class ParentClassNotProvided < Error
      def _gen_message
"Provide Parent class as second argument or block to define your own implementation

example:

    #{@setup.type} #{@setup.method_name}, ParentClass

    # or

    #{@setup.type} #{@setup.method_name} do |hash|
      OpenStruct.new(hash)
    end" 
      end
    end
    class BlockNotProvided < Error
      def _gen_message
"Provide block to set the proper configs

example:
 
    #{@setup.method_name.to_s}(:admin) do
      username 'John'
      password 'qwerty'
    end"
      end
    end
    class InvalidNameError < Error
      def _gen_message
"Provide block to set the proper configs

example:
 
    #{@setup.method_name.to_s}(:admin) do
      # something
    end"
      end
    end
    class Setup
      attr_reader :method_name, :klass, :opts
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
        callee_opts[:_called_method]
      end

      def default_acc
        if type == :named_collectable
          {}
        else
          []
        end
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
            setup_block.call(*args)
          end
        else
          raise ParentClassNotProvided.new(self) unless parent_class
          raise BlockNotProvided.new(self) unless block
          Class.new(klass, &block)
        end
      end
    end
    module ClassMethods
      def collectable(*args, &block)
        setup = Setup.new(*args).tap do |s| 
                  s.callee_opts = {_called_method: __method__}
                  s.setup_block = block
                end
        define_collectable(setup)
      end
  
      def named_collectable(*args, &block)
        setup = Setup.new(*args).tap do |s| 
          s.callee_opts = {_called_method: __method__}
          s.setup_block = block
        end
        define_collectable(setup)
      end
      
      def define_collectable(setup)
        singleton_class.define_method setup.method_name do |*args, &block|
          _set_collectable(setup.acc_name, setup.klass, setup.default_acc)
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
      
      def _set_collectable(name, klass, default)
        self._collectables ||= {}
        self._collectables[name] ||= default 
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
