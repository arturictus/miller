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
 
    #{@setup.method_name.to_s}#{@setup.type == :named_collectable ? "(:my_name_here)" : ''} do
      # This is my block
    end"
      end
    end
    class InvalidNameError < Error
      def _gen_message
"Provide name as first argument

example:
 
    #{@setup.method_name.to_s}(:my_name_here) do
      # something
    end"
      end
    end
  end
end
