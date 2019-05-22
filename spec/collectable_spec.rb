require 'spec_helper'
module Miller
  RSpec.describe Collectable do
    class Attribute < Miller.base(:name, :lastname)
    end
    class ColBaseExample < Collectable
      collectable :property, Attribute
      named_collectable :deployment, Attribute
    end
    class ColExample < ColBaseExample
      property do
        name "hello"
      end
      property do
        name "bye"
      end
      deployment(:app) do
        name :app
      end
    end
    
    it "generates proper metadata" do
      inst = ColExample.new
      expect(ColExample.data[:property].count).to eq 2
      expect(inst.data[:property].count).to eq 2
      expect(inst.data[:property].first.ancestors).to include(Miller::Attribute)
      expect(ColExample.data[:deployment][:app]).not_to be_nil
      expect(inst.data[:deployment][:app]).not_to be_nil
      expect(inst.data[:deployment][:app].ancestors).to include(Miller::Attribute)
    end
  end
end