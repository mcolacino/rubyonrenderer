require 'cgi'
require "erb"
# Il template è un frammento di codice
# in diversi formati (html, xml o wng)
# che contiene un numero n di placeholder
# es: <div class="titolo">{titolo}</div>
# Il codice può essere materialmente salvato sul db
# ma questo aspetto non riguarda strettamente la classe Template

module RenderManager
  class InvalidNameForPlaceholder < Exception
  end

  class Template
    attr_accessor :code, :format, :environments
    def initialize _code
      @code = _code || ''
      @format = :html
      @environments = [:italiano,:inglese]
      @logger = nil
      # TO DO - Occorre definire delle parole non valide per i placeholder
      # Ad esempio quelli degli accessors già esistenti nella classe
      @reserved_words = ['format','code','environments']
      placeholders.each do |ph|
        raise InvalidNameForPlaceholder.new("#{ph} è una parola riservata: non puoi usarla per individuare un placeholder") if @reserved_words.include? ph
        add ph unless self.respond_to? ph
      end
    end
    # Compila il template
    def compile
       code = @code
       placeholders.each {|ph| code = code.gsub("{#{ph}}", "<%=@#{ph}%>")}
      return code
    end
    def get_binding
      binding
    end
    # Esegue il template e accetta come parametro un contesto
    def execute _binding = get_binding
      foo = 'local_erbout'
      erb = ERB.new compile, nil, nil, 'local_erbout'
      erb.result _binding
    end
    # Restituisce un array contenente i placeholder
    # che sono stati inseriti nel template 
    def placeholders
     begin
       @code.scan(/\{([a-z0-9_]{1,})\}/).collect { |ph| ph.first }
     rescue
       []
     end
    end
    # Prima di aggiungere un place_holder
    # devo controllare che l'identificativo scelto non sia in uso
    # e che non contenga caratteri non ammessi
    def add_placeholder _ph
      # Controllo prima i caratteri
      raise InvalidNameForPlaceholder.new("#{_ph} contiene caratteri non ammessi!") if _ph.match(/^[a-z0-9_]{1,}$/).nil?
      # Poi che non sia stato già usato quell'identificativo
      raise InvalidNameForPlaceholder.new("#{_ph} è un identificativo in uso nel template corrente!") if placeholders.include? _ph
      # Se arrivo qui vuol dire che posso procedere...
      add _ph
      @code += "{#{_ph}}"
      return true
    end
    # Rimuovo un placeholder
    def remove_placeholder _ph
      # Ritorno false se il placeholder non esiste
      return false unless placeholders.include? _ph
      # Rimuovo il placeholder
      remove _ph
      @code.gsub!("\{#{_ph}\}",'')
      return true
    end
    # Considero un template valido se tutti i
    # placeholder contenuti hanno un identificativo univoco
    def valid?
      placeholders.size == placeholders.uniq.size
    end
    private
    def add _ph
      methods = %Q{
       def self.#{_ph}
        instance_variable_get("@#{_ph}".to_sym)
       end
       def self.#{_ph}= _p
        instance_variable_set("@#{_ph}".to_sym, _p)
       end
      }
      eval methods
    end
    def remove _ph
      instance_variable_set("@#{_ph}".to_sym, nil)
      methods = %Q{
       def self.#{_ph}
        raise NoMethodError
       end
       def self.#{_ph}= _p
        raise NoMethodError
       end
      }
      eval methods
    end
  end
end
