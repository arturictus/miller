require 'spec_helper'
module Miller
  RSpec.describe Collectable do
    class Attribute < Miller.base(:name, :lastname); end
    class NamedRegistryExample < Hash; end
    class RegistryExample < Array; end

    class ColBaseExample
      include Miller.with(:name, :version)
      include Collectable
      collectable :property, Attribute, acc_name: :properties
      named_collectable :deployment, Attribute
      collectable :user, acc_name: :users do |elems|
        OpenStruct.new(elems)
      end
      named_collectable :named_user, acc_name: :named_users do |elems|
        OpenStruct.new(elems)
      end
      collectable(:array_registry, acc_class: RegistryExample) { |e| e }
      named_collectable(:hash_registry, acc_class: NamedRegistryExample) { |e| e }
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
      deployment(:other_app) do
        name :other_app
      end
      user foo: :bar
      named_user :john, id: 2 
      named_user :paul do
        { id: 4 }
      end
      array_registry 'foo'
      hash_registry :foo, 'elem'
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

    it "own properties" do
      expect(ColExample.config.name).to eq(:my_name)
      expect(ColExample.new.name).to eq(:my_name)
    end

    it 'blocks' do
      inst = ColExample.new
      expect(ColExample._collectables[:users].first.call.foo).to be :bar
      expect(inst._collectables[:named_users][:john].call.id).to be 2
      expect(ColExample._collectables[:named_users][:paul]).to be_a Proc
      expect(inst._collectables[:named_users][:paul].call).to be_a OpenStruct
      expect(inst._collectables[:named_users][:paul].call.id).to be 4
    end

    it 'custom registry' do
      inst = ColExample.new
      expect(ColExample._collectables[:array_registry_acc]).to be_a RegistryExample
      expect(ColExample._collectables[:array_registry_acc].first.call).to eq 'foo'
      expect(ColExample._collectables[:hash_registry_acc]).to be_a NamedRegistryExample
      expect(ColExample._collectables[:hash_registry_acc][:foo].call).to eq 'elem'
    end

    it '_collectable_setups' do
      setups = ColExample._collectable_setups
      expect(setups.all?{ |e| e[1].is_a?(Miller::Collectable::Setup) }).to be true
    end

    it "accessors" do
      expect(ColExample.properties.count).to eq 2
      expect(ColExample.new.properties.count).to eq 2
      expect(ColExample.deployment_acc.count).to eq 2
      expect(ColExample.new.deployment_acc.count).to eq 2
    end
  end
end
