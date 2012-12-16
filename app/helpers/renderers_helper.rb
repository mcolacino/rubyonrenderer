module RenderersHelper
  def render_loader_with_id _id
    %Q{<span id="#{_id}" style="display:none;">Doing ...</span>}
  end

  def render_format_select _mapping
    %Q{
      #{label_tag("format")}
      #{select_tag "format", options_for_select( [:xml,:html,:wng], [_mapping.format] )}
      }
  end
  def render_environments_select _mapping
    checkbox_list = [:italiano, :inglese, :spagnolo].collect do |env|
      %Q{#{check_box_tag("environments", env, _mapping.environments.include?(env))} <span>#{env}</span>}
    end
    return %Q{#{label_tag("environments")}#{checkbox_list}}
  end
  def render_status _obj
    %Q{<span class="status">#{_obj.valid? ? "#{_obj.class.to_s.split('::').last} valido":"#{_obj.class.to_s.split('::').last} non valido"}</span>}
  end
  def render_decoration_type_select
    %Q{
      #{label_tag("dcoration_class", "Decoration Type")}
      #{select_tag "decoration_class", options_for_select( ['RenderManager::MappingManager::Truncator', 'RenderManager::MappingManager::Simple', 'RenderManager::MappingManager::DateFormatter'] )}
      }
  end

end
