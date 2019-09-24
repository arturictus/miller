require "erlash"
require "miller/version"
require "miller/errors"

module Miller
  include Errors
  def self.with(*attrs)

    opts = extract_options!(attrs)

    config_class = Class.new(Hash) do
      alias_method :get, :[]
      alias_method :set, :[]=
      def self.build(hash)
        hash.each_with_object(new) do |(k, v), o|
          o[k] = v
        end
      end
      attrs.each do |attr|
        define_method attr do
          get(attr)
        end
      end

      def method_missing(name, *args, &block)
        raise ConfigNotSetError, { name: name }
      end
    end

    class_methods = Module.new do

      define_method :config do
        @config ||= config_class.build(opts[:default_config] || {})
      end

      def _set_config_from_inheritance(config)
        @config = config
      end

      attrs.each do |attr|
        define_method attr do |*args, &block|
          val = if args.count == 1
                  args.first
                elsif args.count == 0
                  true
                else 
                  args
                end
          config.set(attr, (block || val))
        end
      end
    end

    instance_module = Module.new do
      def config
        self.class.config
      end
      attrs.each do |attr|
        define_method attr do
          result = instance_variable_get("@#{attr}")
          if result
            _extract_config(result)
          else
            _extract_config(self.class.config.get(attr))
          end
        end
      end
      attr_writer *attrs

      private

      def _extract_config(val)
        if val.respond_to?(:call)
          instance_exec(&val)
        else
          val
        end
      end
    end

    Module.new do
      singleton_class.send :define_method, :included do |host_class|
        host_class.extend class_methods
        host_class.include instance_module
      end
    end
  end

  def self.base(*args)
    Class.new do
      include Miller.with(*args)
      def self.inherited(subclass)
        unless config.empty?
          subclass._set_config_from_inheritance(config.dup)
        end
      end
    end
  end

  def self.extract_options!(ary)
    if ary.last.is_a?(Hash) && extractable_options?(ary.last)
      ary.pop
    else
      {}
    end
  end

  def self.extractable_options?(elem)
    elem.instance_of?(Hash)
  end
end
require 'miller/collectable'
