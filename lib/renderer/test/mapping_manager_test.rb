$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'renderer/mapping_manager'

class MappingManagerTest < Test::Unit::TestCase
  include RenderManager
  include RenderManager::MappingManager
  def test_decoration_simple_standalone
    decoration = Simple.new
    decoration.input = 'foo'
    decoration.render
    assert_equal 'foo', decoration.output
    # Provo a serializzare e deserializzare l'oggetto
    decoration = Decoration.load decoration.dump
    assert_nil decoration.output
    decoration.render
    assert_equal 'foo', decoration.output
  end

  def test_decoration_truncator_standalone
    decoration = Truncator.new :limit => 20
    decoration.input = 'Cento anni di solitudine'
    decoration.render
    assert_equal 'Cento anni di so ...', decoration.output
    # Provo a serializzare e deserializzare l'oggetto
    decoration = Decoration.load decoration.dump
    assert_nil decoration.output
    decoration.render
    assert_equal 'Cento anni di so ...', decoration.output
   end

  def test_add_and_remove_decorations_to_a_mapping_item
    item = Item.new 'titolo', 'a_property'
    decoration = Simple.new
    item.add_decoration decoration
    assert_equal 1, item.decorations.size
    another_decoration = Simple.new
    item.add_decoration another_decoration
    assert_equal 2, item.decorations.size
    item.remove_decoration another_decoration
    assert_equal 1, item.decorations.size
    # Verifico che quella rimasta sia effettivamente la prima decoration
    assert (decoration.object_id == item.decorations.first.object_id)
  end

  def test_item_rubify_method
    Struct.new('FakeObject', :a_property)
    @obj = Struct::FakeObject.new
    @obj.a_property = 'Cento anni di solitudine'
    item = Item.new 'titolo', 'a_property'

    # Aggiungo un pò decoration
    item.add_decoration Simple.new
    item.add_decoration Truncator.new :limit => "20"
    # Ne aggiuno anche una non adatta al tipo dato stringa che uso per i test
    # ... Viene semplicemente saltata
    item.add_decoration DateFormatter.new '%Y'
    # ... E non crea problema a quelle successive
    item.add_decoration Uppercaser.new

    assert_nil @proc_for_titolo
    eval item.rubify
    assert_not_nil @proc_for_titolo
    assert @proc_for_titolo.instance_of?(Proc)
    assert_equal 'CENTO ANNI DI SO ...', @proc_for_titolo.call(@obj)
    # Provo a serializzare e deserializzare l'item e ripeto il test
    item = Item.load item.dump
    eval item.rubify
    assert_equal 'CENTO ANNI DI SO ...', @proc_for_titolo.call(@obj)
    # Infine provo a eseguire un item senza conditions
    item.clean_decorations
    eval item.rubify
    assert_equal @obj.a_property, @proc_for_titolo.call(@obj)

  end

  def test_adding_and_removing_an_item_to_mapping

    template = Template.new %Q{<div>{titolo}</div>}
    mapping = Mapping.new template
    item = Item.new 'titolo', 'a_property'
    # Aggiungo un pò decoration
    item.add_decoration Simple.new
    assert_equal 0, mapping.items.size
    mapping.add_item item
    assert_equal 1, mapping.items.size
    mapping.remove_item item
    assert_equal 0, mapping.items.size

  end

  def test_adding_an_item_to_mapping_referred_to_a_placeholder_yet_mapped

    template = Template.new %Q{<div>{titolo}</div>}
    mapping = Mapping.new template
    item = Item.new 'titolo', 'a_property'
    mapping.add_item item
    # Aggiungo un item diverso ma riferito allo stesso placeholder del primo
    another_item = Item.new 'titolo', 'a_property'
    # Viene raisata una eccezione
    assert_raise AmbiguosMappingItem do
      mapping.add_item another_item
    end
    # E non viene aggiunto l'item
    assert_equal 1, mapping.items.size

  end

  def test_adding_an_item_to_mapping_referred_to_a_placeholder_not_include_in_the_template

    template = Template.new %Q{<div>{titolo}</div>}
    mapping = Mapping.new template
    item = Item.new 'falso_placeholder', 'a_property'
    # Viene raisata una eccezione
    assert_raise InvalidMappingItem do
      mapping.add_item item
    end
    # E non viene aggiunto l'item
    assert_equal 0, mapping.items.size

  end

  def test_mapping_validity_check
    template = Template.new %Q{<div>{titolo} {data}</div>}
    mapping = Mapping.new template
    item = Item.new 'titolo', 'a_property'
    mapping.add_item item
    assert_equal false, mapping.valid?
    another_item = Item.new 'data', 'a_property'
    mapping.add_item another_item
    assert_equal true, mapping.valid?
  end

  def test_mapping_dump_and_load

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

    assert_equal true, mapping.valid?
    assert_equal %Q{<div>CENTO ANNI DI SO ... [ del #{data.year} ]</div>}, mapping.test(@obj)

    # Ora faccio il dumping e lo ricarico
    puts mapping.dump.inspect
    mapping = Mapping.load mapping.dump
    # E ripeto il tutto
    assert_equal true, mapping.valid?
    assert_equal %Q{<div>CENTO ANNI DI SO ... [ del #{data.year} ]</div>}, mapping.test(@obj)

  end


end
