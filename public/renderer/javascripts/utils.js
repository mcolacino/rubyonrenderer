// Aggiunge un mapping a un renderer
// Si aspetta unicamente come parametro il render id
function add_mapping(_renderer_id){
  new Ajax.Updater('mappings_' + _renderer_id, '/renderers/add_mapping/', {
    parameters: { id: _renderer_id },
    onLoading: $('loader_add_mapping').toggle(),
    onComplete: $('loader_add_mapping').toggle(),
    insertion: 'bottom'
  });
}
// Elimina un mapping esistente da un renderer in base alla position
// Non richiede l'intero aggiornamento della schermata'
function remove_mapping(_renderer_id, _position){
  new Ajax.Request('/renderers/remove_mapping/', {
    parameters: { id: _renderer_id, position: _position },
    onLoading: function(t) { $('loader_' + _renderer_id + '_' + _position).toggle() },
    onSuccess: function(t) {
       try {
       // Devo cambiare gli id
       $$('#mappings_' + _renderer_id + ' .mapping_wrapper').each(function(el, index){
           // L'elemento che sto per rimuovere lo contrassegno modificandogli l'id
           if(index == _position) {
               el.writeAttribute('id', 'mapping_wrapper_' + _renderer_id + '_' + _position + '_queued_for_hiding');
           };
           // Gli elementi successivi gli scalo l'id di una unità'
           if(index > _position) {
                el.writeAttribute('id', 'mapping_wrapper_' + _renderer_id + '_' + _position)
           };
       })

       // Faccio un bel toggle del singolo elemento
       $('mapping_wrapper_' + _renderer_id + '_' + _position + '_queued_for_hiding').toggle();
       $('loader_' + _renderer_id + '_' + _position).toggle();
       
       } catch(ex) {
           alert(ex.message);
       }
    }
  });
}

function switch_editor_mode (_renderer_id, _position, _mode){
  new Ajax.Updater('template_editor_wrapper_' + _renderer_id + '_' + _position,'/renderers/update_template_code/', {
    parameters: {
        id: _renderer_id,
        position: _position,
        template: $F('template_' + _renderer_id + '_' + _position),
        template_editor_mode: _mode
    },
    evalScripts: true,
    onLoading: function(t) { $('switch_editor_mode_loader_' + _renderer_id + '_' + _position).toggle() },
    onComplete: function(t) {
         // Da aggiungere l'aggiornamento dello stato
    }
  });
}

function load_mapping_item_editor(_evt, _renderer_id, _position, _placeholder){
  new Ajax.Updater('mapping_item_editor_wrapper_' + _renderer_id + '_' + _position,'/renderers/update_mapping_item/', {
    parameters: {
        id: _renderer_id,
        position: _position,
        placeholder: _placeholder.innerHTML
    },
    evalScripts: true,
    onComplete: function(t) {
        // Da aggiungere l'aggiornamento dello stato
    }
  });
  
}
function foo(){
 alert('ok');
  new Ajax.Updater('foo_wrapper','/users/foo/', {
    parameters: {}
  });
}
