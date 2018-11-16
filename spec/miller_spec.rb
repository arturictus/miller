RSpec.describe Miller do
  it "has a version number" do
    expect(Miller::VERSION).not_to be nil
  end

  describe 'adding DSL to a class' do
    it 'example' do
      klass = Class.new do
        include Miller.with(:name, :lastname)
        name 'John'
        lastname 'Doe'
      end
      expect(klass.config.name).to eq 'John'
      expect(klass.config.lastname).to eq 'Doe'
      inst = klass.new
      expect(inst.name).to eq 'John'
      expect(inst.lastname).to eq 'Doe'
    end
    it 'blocks' do
      klass = Class.new do
        include Miller.with(:name, :lastname)
        name { another_name }
        lastname 'Doe'

        def another_name
          "victor"
        end
      end
      expect(klass.config.name).to be_a Proc
      expect(klass.config.lastname).to eq 'Doe'
      inst = klass.new
      expect(inst.name).to eq 'victor'
      expect(inst.lastname).to eq 'Doe'
    end
    it 'default config' do
      klass = Class.new do
        include Miller.with(:name, :lastname, default_config: { name: 'Henry', lastname: 'Miller' })
        lastname 'Doe'
      end
      expect(klass.config.name).to eq 'Henry'
      expect(klass.config.lastname).to eq 'Doe'
      inst = klass.new
      expect(inst.name).to eq 'Henry'
      expect(inst.lastname).to eq 'Doe'
    end
    it 'instance override' do
      klass = Class.new do
        include Miller.with(:name, :lastname)
        name 'John'
        lastname 'Doe'
      end
      expect(klass.config.name).to eq 'John'
      expect(klass.config.lastname).to eq 'Doe'
      inst = klass.new
      inst.name = 'Henry'
      expect(inst.name).to eq 'Henry'
      expect(inst.lastname).to eq 'Doe'
    end
    it 'instance override with block' do
      klass = Class.new do
        include Miller.with(:name, :lastname)
        name 'John'
        lastname 'Doe'
        def another_name
          'Martha'
        end
      end
      expect(klass.config.name).to eq 'John'
      expect(klass.config.lastname).to eq 'Doe'
      inst = klass.new
      inst.name = proc { another_name }
      expect(inst.name).to eq 'Martha'
      expect(inst.lastname).to eq 'Doe'
    end
    it 'inheritance' do
      super_klass = Class.new do
        include Miller.with(:name, :lastname)
        name 'John'
        lastname 'Doe'
      end
      klass = Class.new(super_klass)
      expect(klass.config.name).to eq 'John'
      expect(klass.config.lastname).to eq 'Doe'
      inst = klass.new
      expect(inst.name).to eq 'John'
      expect(inst.lastname).to eq 'Doe'
    end
  end
end
