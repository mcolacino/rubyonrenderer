class Renderer < ActiveRecord::Base
  serialize :mappings
  include RenderManager
  include RenderManager::MappingManager

  def get_mappings
    mappings.map {|m| Mapping.load m }
  end
  def get_valid_mappings
    get_mappings.select {|m| m.valid?}
  end

  def add_mapping
    m = Mapping.new
    mappings << m.dump
    save
    m
  end
  def remove_mapping _position
    mappings.delete_at _position
    save
  end
  def find_mapping _format, &block
    m = get_valid_mappings.select {|m| m.format == _format }
    return if m.empty?
    m.first.set
    yield m.first
  end
  def compile
    r = Reifier.new "Testing", self.id
    r.mappings = get_mappings
    r.reify!
        load "#{r.class_path_root}/visualization#{self.id}_sub0.rb"

    load "#{r.class_path_root}/visualization#{self.id}.rb"
    #mappings.size.times { |n| load "#{r.class_path_root}/visualization_#{self.id}_sub_#{n.to_s}.rb" }
  end

end
