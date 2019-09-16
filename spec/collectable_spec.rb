require 'spec_helper'
module Miller
  RSpec.describe Collectable do
    class Attribute < Miller.base(:name, :lastname); end
    
    class ColBaseExample
      include Miller.with(:name, :version)
      include Collectable
      collectable :property, parent: Attribute, acc_name: :properties
      named_collectable :deployment, parent: Attribute
      collectable :storage, acc_name: :storages do |input|
        OpenStruct.new(input)
      end
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
      storage do
        {foo: :bar}
      end
      deployment(:app) do
        name :app
      end
      deployment(:other_app) do
        name :other_app
      end
    end

    it "generates proper metadata" do
      inst = ColExample.new
      expect(ColExample._collectables[:properties].count).to eq 2
      expect(inst._collectables[:properties].count).to eq 2
      expect(inst._collectables[:properties].first.ancestors).to include(Miller::Attribute)
      expect(ColExample._collectables[:deployment_acc][:app]).not_to be_nil
      expect(inst._collectables[:deployment_acc][:app]).not_to be_nil
      expect(inst._collectables[:deployment_acc][:app].ancestors).to include(Miller::Attribute)
    end

    it 'block defined collectable' do
      expect(ColExample.storages.first.foo).to eq :bar
    end

    it "own properties" do
      expect(ColExample.config.name).to eq(:my_name)
      expect(ColExample.new.name).to eq(:my_name)
    end
    it "accessors" do
      expect(ColExample.properties.count).to eq 2
      expect(ColExample.new.properties.count).to eq 2
      expect(ColExample.deployment_acc.count).to eq 2
      expect(ColExample.new.deployment_acc.count).to eq 2
    end
  end
end
