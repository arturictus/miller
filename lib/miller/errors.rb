module Miller
  module Errors
    class ConfigNotSetError < Erlash::Base
      display_context false
      problem do |c|
        "Config not set: `#{c[:name]}`"
      end
      resolution do |c|
        "Register the config when including Miller, ex: `include Miller.with(:#{c[:name]})`"
      end
    end
  end
end
