class CreateRenderers < ActiveRecord::Migration
  def self.up
    create_table :renderers do |t|
      t.column "title", :string
      t.column "description", :text
      t.column "mappings", :text
      t.timestamps
    end
  end

  def self.down
    drop_table :renderers
  end
end
