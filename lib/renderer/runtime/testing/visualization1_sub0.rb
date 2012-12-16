

     module RenderManager
     module Testing

     require 'renderer/template.rb'
     require 'renderer/mapping_manager.rb'
     require 'renderer/runtime/testing/visualization1'
   
     class Visualization1Sub0 < Visualization1

     def self.format
        :html
     end

     # Gli accessor sono definiti dinamicamente
     # a partire dai placeholder contenuti nel template
     attr_accessor :titolino, :anno

     # Le proc per calcolare invece il valore dei campi
     # le salvo come costanti
     
      @@proc_for_titolino = Proc.new do |resource|
         begin
           input = resource.send "ok"
           
           input
         rescue Exception => ex
           ex.message
         end
      end
     
      @@proc_for_anno = Proc.new do |resource|
         begin
           input = resource.send ""
           
           input
         rescue Exception => ex
           ex.message
         end
      end
     

     # Idem per il template
     @@template = Template.new %Q{"<div class="titolo">{titolino} {anno}</div>
"}

     def initialize _resource
     
        @titolino = @@proc_for_TITOLINO.call(_resource)
      
        @anno = @@proc_for_ANNO.call(_resource)
      
     end
     end

   end
   end
   