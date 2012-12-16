

        
     module RenderManager
     module Testing

     class Visualization1
        @@sub_classes = [ "RenderManager::Testing::Visualization1Sub0", "RenderManager::Testing::Visualization1Sub1" ]

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
   