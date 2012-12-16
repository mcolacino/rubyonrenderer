require 'fileutils'

# Il Reifier si occupa semplicemente di reificare un mapping in una classe ruby
# Questa classe viene generata a runtime è quella che verra usata effettivamente nel rendering
# Tutte queste classi ereditano da Visualization

module RenderManager

class Reifier
  attr_accessor :mappings, :project, :identifier, :class_path_root
  def initialize _project, _identifier
    @mappings = []
    @project = _project.downcase
    @identifier = _identifier
    @class_path_root = "/Users/marcello/Desktop/Renderer/app/lib/renderer/runtime/#{@project}"
  end
  # Stampa il codice, ma non crea il file
  def reify
   output = {}

     output["visualization#{@identifier.to_s.capitalize}"] = %{

        
     module RenderManager
     module #{@project.capitalize}

     class Visualization#{@identifier.to_s.capitalize}
        #{set_subclasses}

        # Accetta un blocco e rende disponibile nel blocco un renderer
        # Se non esiste un renderer adatto al formato passato non processa il blocco
        def self.do _format, &block
          # Provvisoriamente implementato solo il format
          renderer = @@sub_classes.select {|s| s.constantize.format == _format }
          # Esegue il codice passato nel blocco solo se viene trovato un renderer adatto
          return if renderer.empty?
          # Esegue il blocco passando il renderer come parametro
          yield renderer.first
        end

        # Metodo che esegue il render
        def do _binding = get_binding
          @@template.execute _binding
        end

        def get_binding
          binding
        end
     end

     end
     end
   }

   @mappings.select {|m| m.valid? }.each_with_index do |mapping, index|
   
   output["visualization#{@identifier.to_s.capitalize}_sub#{index}"] = %{

     module RenderManager
     module #{@project.capitalize}

     require 'renderer/template.rb'
     require 'renderer/mapping_manager.rb'
     require 'renderer/runtime/#{@project}/visualization#{@identifier.to_s.capitalize}'
   
     class Visualization#{@identifier.to_s.capitalize}Sub#{index} < Visualization#{@identifier.to_s.capitalize}

     def self.format
        :#{mapping.template.format}
     end

     # Gli accessor sono definiti dinamicamente
     # a partire dai placeholder contenuti nel template
     #{set_attr_accessors mapping}

     # Le proc per calcolare invece il valore dei campi
     # le salvo come costanti
     #{set_placeholder_procs_as_constants mapping}

     # Idem per il template
     #{set_template_as_constant mapping}

     def initialize _resource
     #{set_instance_variables mapping}
     end
     end

   end
   end
   }
   return output
   end
  end
  # Crea materialmente il file
  def reify!
   # return unless @mapping.valid?
   code = reify
   code.each_pair do |filename, content|
   FileUtils.mkpath(File.dirname("#{@class_path_root}/#{filename}.rb"))
   # Creo il file
   File.open("#{@class_path_root}/#{filename}.rb", "w") do |f|
     f.write(content)
   end
   if File.exist?("#{@class_path_root}/#{filename}.rb")
     # In questo caso devo ricaricarla in memoria
     reload
   end
   end
  end

  # Ricarica la classe in memoria.
  def reload
     # ::Dependencies.remove_const("Visualization#{@identifier.to_s.capitalize}")
     # load @class_path
  end

  private
  # Scrivo una variabile di classe contenente l'array delle sottoclassi corrispondenti
  def set_subclasses
    sc = []
    @mappings.select {|m| m.valid? }.each_with_index do |m,index|
      sc << %Q{"RenderManager::#{@project.capitalize}::Visualization#{@identifier.to_s.capitalize}Sub#{index}"}
    end
    %Q{@@sub_classes = [ #{sc.join(', ')} ]}
  end
  # Mentre per tutte la parte di test e composizione del mapping
  # mi fa comodo che le proc siano variabili di classe
  # qui, per ragioni di efficienza, le trasformo in costanti
  def set_placeholder_procs_as_constants _mapping
    procs = ''
    _mapping.items.each do |i|
      procs += i.rubify.gsub(Regexp.new("@proc_for_#{i.placeholder}"),"@@proc_for_#{i.placeholder}")
    end
    procs
  end
  # Anche il template lo tratto come costante
  def set_template_as_constant _mapping
    %Q{@@template = Template.new %Q{"#{_mapping.template.code}"}}
  end
  # Dai placeholder del template mi ricavo gli accessor che mi occorrono
  def set_attr_accessors _mapping
    %Q{attr_accessor #{_mapping.template.placeholders.map {|ph| ":#{ph}"}.join(', ')}}
  end
  # Dai placeholder del template mi ricavo gli accessor che mi occorrono
  def set_instance_variables _mapping
    _mapping.template.placeholders.map do |ph|
      %Q{
        @#{ph} = @@proc_for_#{ph.upcase}.call(_resource)
      }
    end
  end
  # Setto i requires per la superclasse
  def set_requires
    sc = ''
    @mappings.select{|m| m.valid?}.each_with_index do |m,index|
      sc += %Q{require 'renderer/runtime/#{@project}/visualization#{@identifier.to_s.capitalize}_sub#{index}.rb'\n}
    end
    sc
  end
end

end