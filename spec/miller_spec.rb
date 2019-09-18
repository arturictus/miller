RSpec.describe Miller do
  it "has a version number" do
    expect(Miller::VERSION).not_to be nil
  end

  describe 'adding DSL to a class' do
    it 'common example' do
      dsl = Class.new do
        include Miller.with(:name, :lastname)
        def full_name
          "#{name} #{lastname}"
        end
        # write your logic here
      end
      klass = Class.new(dsl) do
        name 'John'
        lastname 'Doe'
      end
      expect(klass.config.name).to eq 'John'
      expect(klass.config.lastname).to eq 'Doe'
      inst = klass.new
      expect(inst.name).to eq 'John'
      expect(inst.lastname).to eq 'Doe'
      expect(inst.full_name).to eq 'John Doe'
    end
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
    it "errors when config not set" do
      klass = Class.new do
        include Miller.with(:name, :lastname)
        name 'John'
        lastname 'Doe'
      end
      expect {
        klass.config.foo
      }.to raise_error(Miller::ConfigNotSetError)
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
      super_klass = Class.new(Miller.base(:name, :lastname)) do
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
    it 'multiple arguments' do
      klass = Class.new(Miller.base(:names, :tags, :cache)) do
        names 'John', "John"
        tags foo: :bar
        cache
      end
      expect(klass.config.names).to eq ['John', 'John']
      expect(klass.new.names).to eq ['John', 'John']
      expect(klass.config.tags).to eq({foo: :bar})
      expect(klass.new.tags).to eq({foo: :bar})
      expect(klass.config.cache).to eq(true)
      expect(klass.new.cache).to eq(true)
    end
  end
end
