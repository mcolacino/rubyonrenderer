require 'renderer/template'
require 'cgi'

module RenderManager
 module MappingManager

 class BadSerializedDataError < Exception; end
 class AmbiguosMappingItem < Exception; end
 class InvalidMappingItem < Exception; end
 class InvalidMapping < Exception; end

 # Il Mapping Manager si occupa di gestire il mapping
 # tra placeholder del template e i valori che arrivano dall'oggetto Rendered
 # Il Mapping è un array di Oggetti Item
 # Internamente mantiene un riferimento a un template (RenderManager::Template)
 # Tutte le componenti del mapping - Mapping, Item, Decoration
 # espongono un metodo di istanza dump e uno di classe load per la serializzazione
 
 class Mapping
   attr_accessor :items, :template, :format, :environments
   # Di default viene creato con un template vuoto
   def initialize _template = Template.new('')
     @items = []
     @template = _template
     @format = @template.format
     @environments = @template.environments
   end

   def self.load _serialized_obj
     # Creo il template
     t = Template.new _serialized_obj[:template]
     # Creo l'oggetto Mapping
     obj = self.new t
     # E aggiungo gli item necessarie
     _serialized_obj[:items].each {|i| obj.add_item Item.load(i) }
     return obj
   rescue Exception => ex
     raise BadSerializedDataError.new ex.message
   end

   def dump
     return {
       :template => template.code,
       :items => items.collect { |i| i.dump }
     }
   end

   # Ridefinisco questo accessor perchè
   # in caso di aggiornamento del template, non mi basta aggiornare l'oggetto template
   # ma devo anche eliminare tutti gli item che contengono eventuali riferimenti
   # a placeholder non previsti dal nuovo template
   def template= _template
     @template = _template
     @items.reject! {|i| !@template.placeholders.include? i.placeholder}
     @template
   end

   # Se il mapping è valido posso testarlo...
   # Ovviamente mi serve di passare un oggetto fake come parametro
   # Divido il metodo in due sottometodi perchè mi può convenire
   # in determinati casi di eseguire il setting delle proc
   # una sola volta e l'esecuzione delle medesime enne volte
   def test _obj, _binding = nil
     raise InvalidMapping unless valid?
     set _binding
     run
   end
   # Metodo che definisce le proc come variabili di istanza
   def set
     @items.each do |d|
       eval d.rubify
     end
   end
   # Metodo che esegue le proc definite da set
   def run _obj, _binding = nil
     @template.placeholders.each do |ph|
       proc = instance_variable_get("@proc_for_#{ph}".to_sym)
       @template.send("#{ph}=",proc.call(_obj))
     end
     @template.execute 
   end

   # Il mapping è valido se è stato definito un item di mapping
   # per ogni item presente nel template
   # Metodo da usare ad esempio per evitare di generare delle classi incomplete
   # La generazione della classe può avere un senso solo se il mapping è valido
   def valid?
     template.placeholders.size == items.size
   end
   # Stampa una versione visualizzabile del template
   # Prima era un metodo della classe template
   # ma ha più senso che sia un metodo del mapping
   # visto che vengono evidenziati i placeholder in modo diverso
   # in funzione del fatto che siano stati già verificati o meno
   def show_template
      # In primo luogo effetuo l'escape del codice in modo rendere il markup visibile
      code = CGI::escapeHTML @template.code
      # Poi riscrivo i placeholder in modo da renderli evidenziabili via css
      # In particolare li wrappo in uno span e indico con una classe se sono stati associati a un valore o no
      @template.placeholders.each do |ph|
        css_class_name = include?(ph) ? 'placeholder set' : 'placeholder unset'
        code.gsub!("{#{ph}}","<span class=\"#{css_class_name}\">#{ph}</span>")
      end
      return %Q{#{code}}
   end
   # Verifica se è presente, e se è valido
   # un item associato al placeholder passato come parametro
   def include? _ph
     related_item = item_for _ph
     return false if related_item.nil?
     return related_item.valid?
   end
   # Recupera l'item corrispondente al placeholder passato come parametro
   # Se non esiste, il metodo ritorna nil
   def item_for _ph
     @items.select {|i| i.placeholder == _ph }.first
   rescue
     nil
   end
   def rubify
     return %Q{#{@items.collect {|i| i.rubify }}}
   end
   # Questo metodo  recupera il mapping item
   # corrispondente a un determinato placeholder
   # Se non lo trova, ne crea uno e lo aggiunge
   def get_item_for_placeholder_if_exists_or_create_it _ph
     # Controllo che non mi stiano passando nil come argomento
     raise InvalidNameForPlaceholder.new("") if _ph.blank?
     i = item_for _ph
     return i unless i.nil?
     new_item = Item.new(_ph, '')
     add_item new_item
     new_item
   end
   def add_item _i
     raise InvalidMappingItem unless @template.respond_to? _i.placeholder
     raise AmbiguosMappingItem if @items.map {|i| i.placeholder }.include? _i.placeholder
     @items.push _i
     true
   end
   def remove_item _i
     @items.reject! {|i| i === _i}
     true
   end
   def remove_item_at _index
     @items.delete_at _index
     true
   end

 end

 # In un mapping un item è composto da
 # un riferimento a un placeholder di un template
 # un valore di input
 # un serie ordinata di trasformazioni (Decoration) da applicare all'item
 # e un valore di output
 
 class Item
   attr_accessor :placeholder, :decorations, :input, :output
   def initialize _placeholder, _input
     @decorations = []
     @placeholder = _placeholder
     @input = _input
   end
   def self.load _serialized_obj
     # Creo l'oggetto
     obj = self.new _serialized_obj[:placeholder], _serialized_obj[:input]
     # E aggiungo le decoration necessarie
     _serialized_obj[:decorations].each {|d| obj.add_decoration Decoration.load(d) }
     return obj
   rescue Exception => ex
     return ex.message
     raise BadSerializedDataError.new ex.message
   end
   # Il mapping item non è valido sicuramente se
   # ha come input una stringa vuota
   def valid?
     !@input.blank?
   end

   def dump
     return {
       :placeholder => @placeholder,
       :input => @input,
       :decorations => @decorations.collect { |d| d.dump }
     }
   end
   def add_decoration _d
     @decorations.push _d
     _d
   end
   def remove_decoration _d
     @decorations.reject! {|d| d === _d}
   end
   def remove_decoration_at _index
     @decorations.delete_at _index
   end
   def clean_decorations
     @decorations = []
   end
   # Considero l'input come proc
   def rubify
     %Q{
      @proc_for_#{placeholder} = Proc.new do |resource|
         begin
           input = resource.send "#{input}"
           #{decorations.collect {|d| d.rubify }}
           input
         rescue Exception => ex
           ex.message
         end
      end
     }
   end
 end

 # Una decoration ha un certo numero di parametri
 # Accetta una valore come input e ritorna un output
 class Decoration
   attr_accessor :input, :output, :params, :params_definition, :allowed_input_data_types, :partial
   def initialize _params = {}
     @params = _params
     @params_definition = []
     @allowed_input_data_types = []
     # Nome del partial da usare per l'interfaccia di editing delle varie decoration
     @partial = :common
   end
   def self.load _serialized_obj
     obj_class = eval _serialized_obj[:class]
     obj = obj_class.new _serialized_obj[:params]
     obj.input = _serialized_obj[:input]
     return obj
   rescue Exception => ex
     raise BadSerializedDataError.new ex.message
   end
   # Valida se tutte gli argomenti richiesti sono valorizzati
   def valid?
     @params_definition.each { |pd| return false unless @params.has_key?(pd) }
     true
   end
   def executable?
     @allowed_input_data_types.include? @input.class
   end
   def dump
     return {
       :class => self.class.to_s,
       :input => @input,
       :params => @params
     }
   end

   def rubify
     return %Q{
           r = #{self.class}.new(#{@params.inspect})
           r.input = input
           input = r.render if r.executable?
     }
   end
 end

 # Decoration di base... Non effettua trasformazioni
 # La uso solo per i test
 class Simple < Decoration
   def initialize _params = {}
     @params = _params
     @allowed_input_data_types = [String]
          @params_definition = []

     @partial = :common

   end
   def render
     @output = @input
     return @output
   end
 end
 # Uppercaser... Testo in Maiuscolo
 class Uppercaser < Decoration
   def initialize _params = {}
     @params = _params
     @params_definition = []

     @allowed_input_data_types = [String]
     @partial = :common

   end
   def render
     @output = @input.upcase
     return @output
   end
 end

 # Truncator... Tronca il testo
 class Truncator < Decoration
   def initialize _params = {}
     @params = _params
     @params_definition = [:limit]
     @allowed_input_data_types = [String]
     @limit = @params[:limit].to_i
     @partial = :common

   end
   def render
     @output = (@input.size > @limit) ? "#{@input.slice(0,(@limit - 4))} ..." : @input
     return @output
   end
 end

 # Formatta le date
 class DateFormatter < Decoration
   def initialize _params = {}
     @params = _params
     @params_definition = [:format]
     @allowed_input_data_types = [Time, DateTime, ActiveSupport::TimeWithZone]
     @format = _params[:format]
     @partial = :common

   end
   def render
     @output = @input.strftime @format
     return @output
   end
 end

 end
end