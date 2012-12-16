class RenderersController < ApplicationController
  include RenderManager
  include RenderManager::MappingManager

  # GET /renderers
  # GET /renderers.xml
  def index
    @renderers = Renderer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @renderers }
    end
  end

  # GET /renderers/1
  # GET /renderers/1.xml
  def show
    @renderer = Renderer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @renderer }
    end
  end

  # GET /renderers/new
  # GET /renderers/new.xml
  def new
    @renderer = Renderer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @renderer }
    end
  end

  # GET /renderers/1/edit
  def edit
    @renderer = Renderer.find(params[:id])
  end

  # POST /renderers
  # POST /renderers.xml
  def create
    @renderer = Renderer.new(params[:renderer])

    respond_to do |format|
      if @renderer.save
        flash[:notice] = 'Renderer was successfully created.'
        format.html { redirect_to(@renderer) }
        format.xml  { render :xml => @renderer, :status => :created, :location => @renderer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @renderer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /renderers/1
  # PUT /renderers/1.xml
  def update
    @renderer = Renderer.find(params[:id])

    respond_to do |format|
      if @renderer.update_attributes(params[:renderer])
        flash[:notice] = 'Renderer was successfully updated.'
        format.html { redirect_to(@renderer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @renderer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /renderers/1
  # DELETE /renderers/1.xml
  def destroy
    @renderer = Renderer.find(params[:id])
    @renderer.destroy

    respond_to do |format|
      format.html { redirect_to(renderers_url) }
      format.xml  { head :ok }
    end
  end
  ###########################################

  # Aggiunge un nuovo mapping a una istanza di renderer
  def add_mapping
    @renderer = Renderer.find params[:id]
    @mapping = @renderer.add_mapping
    # La posizione la calcolo in tempo reale
    @position = @renderer.mappings.size - 1
    render :partial => 'mapping'
  end
  # Rimuove un mapping in base alla posizione da una istanza di renderer
  def remove_mapping
    @renderer = Renderer.find params[:id]
    @renderer.remove_mapping params[:position].to_i
    render :text => 'foo'
  end
  def update_template_code
    @renderer = Renderer.find params[:id]
    @position = params[:position].to_i
    @mapping = @renderer.get_mappings[@position]
    @mapping.template= Template.new %Q{#{params[:template]}}
    @renderer.mappings[@position] = @mapping.dump
    @renderer.save
    @template_editor_mode = (params[:template_editor_mode].to_sym == :edit) ? :preview : :edit
    render :partial => 'template_editor'
  end
  def update_mapping_item
    @renderer = Renderer.find params[:id]
    @position = params[:position].to_i
    @mapping = @renderer.get_mappings[@position]
    @item = @mapping.get_item_for_placeholder_if_exists_or_create_it params[:placeholder]
    @item.input = params[:input] unless params[:input].nil?
    @renderer.mappings[@position] = @mapping.dump
    @renderer.save
    render :partial => 'mapping_item_editor'
  end
  def add_decoration_to_a_mapping_item
    @renderer = Renderer.find params[:id]
    @position = params[:position].to_i
    @mapping = @renderer.get_mappings[@position]
    @item = @mapping.get_item_for_placeholder_if_exists_or_create_it params[:placeholder]
    # Creo la nuova decoration non valida, ovvero senza parametri
    @decoration = @item.add_decoration params[:decoration_class].constantize.new
    @decoration_position = (@item.decorations.size - 1)
    # Aggiorno il mapping
    @renderer.mappings[@position] = @mapping.dump
    @renderer.save
    render :partial => 'single_decoration_editor'

  end
  def update_decoration_for_a_mapping_item
    @renderer = Renderer.find params[:id]
    @position = params[:position].to_i
    @mapping = @renderer.get_mappings[@position]
    @item = @mapping.item_for params[:placeholder]
    # Creo la nuova decoration non valida, ovvero senza parametri
    @decoration_position = params[:decoration_position].to_i
    # Salva i valori della decoration
    @item.decorations.each_with_index do |decoration, decoration_position|
      if @decoration_position == decoration_position
        decoration.params_definition.each {|arg| decoration.params[arg] = params[arg]}
      end
    end
    @decoration = @item.decorations[@decoration_position]
    # Aggiorno il mapping
    @renderer.mappings[@position] = @mapping.dump
    @renderer.save
    render :partial => 'single_decoration_editor'
  end
  def delete_decoration_from_a_mapping_item
    @renderer = Renderer.find params[:id]
    @position = params[:position].to_i
    @mapping = @renderer.get_mappings[@position]
    @item = @mapping.item_for params[:placeholder]
    @decoration_position = params[:decoration_position].to_i
    @item.remove_decoration_at @decoration_position unless @item.nil?
    @renderer.mappings[@position] = @mapping.dump
    @renderer.save
    render :partial => 'decoration_editor'
  end

end
