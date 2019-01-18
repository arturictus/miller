require 'spec_helper'

class Hello < Miller.base(:name, :lastname)
end

class Name < Hello
  name "name"
end
class Lastname < Hello
  lastname 'lastname'
end
class NameChild < Name
  lastname 'name_child'
end

RSpec.describe 'Parents do not get updated by childs' do
  it do
    expect(Lastname.config.name).to be nil
    expect(Name.config.lastname).to be nil
    expect(Hello.config.lastname).to be nil
    expect(Hello.config.name).to be nil
    expect(NameChild.config.name).to eq "name"
    expect(NameChild.config.lastname).to eq "name_child"
  end
end
