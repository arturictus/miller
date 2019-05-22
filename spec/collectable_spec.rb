require 'spec_helper'
module Miller
  RSpec.describe Collectable do
    class Attribute < Miller.base(:name, :lastname)
    end
    class ColBaseExample < Collectable
      include Miller.with(:name, :version)
      collectable :property, Attribute
      named_collectable :deployment, Attribute
    end
    class ColExample < ColBaseExample
      name :my_name
      version "0.1.0"
      
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
      expect(ColExample._collectables[:property].count).to eq 2
      expect(inst._collectables[:property].count).to eq 2
      expect(inst._collectables[:property].first.ancestors).to include(Miller::Attribute)
      expect(ColExample._collectables[:deployment][:app]).not_to be_nil
      expect(inst._collectables[:deployment][:app]).not_to be_nil
      expect(inst._collectables[:deployment][:app].ancestors).to include(Miller::Attribute)
    end

    it "own properties" do
      expect(ColExample.config.name).to eq(:my_name)
      expect(ColExample.new.name).to eq(:my_name)
    end
    it "accessors" do
      expect(ColExample.property_col.count).to eq 2
      expect(ColExample.new.property_col.count).to eq 2
    end
  end
end