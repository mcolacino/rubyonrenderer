# require 'active_support'
# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'

require 'renderer/reifier'
require 'renderer/template'
require 'renderer/mapping_manager'

class ReifierTest < Test::Unit::TestCase

  include RenderManager
  include RenderManager::MappingManager

  def test_foo
    # Creo il mapping di test
    Struct.new('AnotherFakeObject', :titolo, :data)
    data = Time.now
    @obj = Struct::AnotherFakeObject.new
    @obj.titolo = 'Cento anni di solitudine'
    @obj.data = data

    template = Template.new %Q{<div>{intestazione} [ del {data} ]</div>}
    mapping = Mapping.new template
    item = Item.new 'intestazione', 'titolo'
    item.add_decoration Truncator.new :limit => "20"
    item.add_decoration Uppercaser.new
    mapping.add_item item
    another_item = Item.new 'data', 'data'
    another_item.add_decoration DateFormatter.new :format => "%Y"
    mapping.add_item another_item

    reified_obj = RenderManager::Reifier.new mapping, 'testing', 1
    reified_obj.reify!
    load reified_obj.class_path
    renderer = RenderManager::Testing::Visualization1.new @obj
    assert_equal %Q{<div>CENTO ANNI DI SO ... [ del #{data.year} ]</div>}, mapping.test(@obj)
    # Cmabio il template
    mapping.template = Template.new %Q{<div>{intestazione} [ del {data} ]</div> (modificato)}
    reified_obj = RenderManager::Reifier.new mapping, 'testing', 1
    reified_obj.reify!
    # load reified_obj.class_path
    renderer = RenderManager::Testing::Visualization1.new @obj
    assert_equal %Q{<div>CENTO ANNI DI SO ... [ del #{data.year} ]</div> (modificato)}, mapping.test(@obj)

  end
end
