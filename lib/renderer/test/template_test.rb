# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib/')

require 'test/unit'
require 'renderer/template'

class TemplateTest < Test::Unit::TestCase
  include RenderManager
  def test_placeholders_counting
    @template = Template.new %Q{<div class="titolo">{titolo}</div>}
    # Un template con un unico ph
    assert_equal 1, @template.placeholders.size
    # Un template con due placeholder
    @template2 = Template.new %Q{<div class="titolo">{titolo} <span>{data}</span></div>}
    assert_equal 2, @template2.placeholders.size
    assert @template2.valid?
    # Un template con due placeholder,
    # dei quali uno con identificativo non valido
    # Mi attendo che quello non valido non venga riconosciuto
    @template3 = Template.new %Q{<div class="titolo">{titolo} {WrongId}<span>{data}</span></div>}
    assert_equal 2, @template3.placeholders.size
  end

  def test_adding_a_new_valid_placeholder
    @template = Template.new %Q{<div class="titolo">{titolo}</div>}
    assert @template.add_placeholder('nome')
    # Verifico che abbia effettivamente fatto l'operazione
    assert_equal %Q{<div class="titolo">{titolo}</div>{nome}}, @template.code
    # Verifico che gli accessors creati per il placeholder siano funzionanti
    assert_equal nil, @template.nome
    @template.nome = 'foo'
    assert_equal 'foo', @template.nome
  end

  def test_adding_a_new_placeholder_invalid_becouse_yet_used
    @template = Template.new %Q{<div class="titolo">{titolo}</div>}
    assert_raise InvalidNameForPlaceholder do
      @template.add_placeholder('titolo')
    end

  end

  def test_adding_a_new_placeholder_invalid_becouse_not_compliant
    @template = Template.new %Q{<div class="titolo">{titolo}</div>}
    assert_raise InvalidNameForPlaceholder do
      @template.add_placeholder('Nome')
    end
  end

  def test_adding_a_new_placeholder_invalid_becouse_included_in_reserved_words
    assert_raise InvalidNameForPlaceholder do
      @template = Template.new %Q{<div class="titolo">{format}</div>}
    end
  end

  def test_removing_an_existing_placeholder
    @template = Template.new %Q{<div class="titolo">{titolo}</div>}
    assert @template.remove_placeholder('titolo')
    # Verifico che abbia effettivamente fatto l'operazione
    assert_equal %Q{<div class="titolo"></div>}, @template.code
    # E che vada in errore il methodo
    assert_raise NoMethodError do
      @template.titolo
    end

  end

  def test_removing_a_non_existing_placeholder
    @template = Template.new ''
    # Un template con un unico ph
    @template.code = %Q{<div class="titolo">{titolo}</div>}
    assert_equal false, @template.remove_placeholder('data')
  end

  def test_showing_feature
    @template = Template.new %Q{<div class="titolo">{titolo}</div>}
    assert_equal %Q{&lt;div class=&quot;titolo&quot;&gt;<span class="placeholder unset">titolo</span>&lt;/div&gt;}, @template.show
    @template.titolo = 'foo'
    assert_equal 'foo', @template.titolo
    assert_equal %Q{&lt;div class=&quot;titolo&quot;&gt;<span class="placeholder set">titolo</span>&lt;/div&gt;}, @template.show
  end

  def test_compile_feature
    @template = Template.new %Q{<div class="titolo">{titolo}</div>}
    assert @template.respond_to? 'titolo'
    assert_equal nil, @template.titolo
    code_before_compiling = @template.code
    assert_equal %Q{<div class="titolo"><%=@titolo%></div>}, @template.compile
    assert_equal code_before_compiling, @template.code
    @template.titolo = 'foo'
    assert_equal 'foo', @template.titolo
    assert_equal %Q{<div class="titolo"><%=@titolo%></div>}, @template.compile
    assert_equal %Q{<div class="titolo">foo</div>}, @template.execute(@template.get_binding)
  end

  def test_execute_feature
    @template = Template.new %Q{<div class="titolo">{titolo}</div>}
    @template.titolo = 'foo'
    assert_equal 'foo', @template.titolo
    assert_equal %Q{<div class="titolo">foo</div>}, @template.execute(@template.get_binding)
  end

  def test_dynamic_accessors_created_on_placeholder

    @template1 = Template.new %Q{<div class="titolo">{titolo}</div>}
    assert @template1.respond_to? 'titolo'
    @template1.add_placeholder 'data'
    assert @template1.respond_to? 'data'
    @template2 = Template.new %Q{<div class="titolo">{titolo}</div>}
    assert @template2.respond_to? 'titolo'
    assert_equal false, @template2.respond_to?('data')
  end

end
