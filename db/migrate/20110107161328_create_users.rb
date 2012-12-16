class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column "username", :string
      t.column "password", :string
      t.column "email", :string
      t.column "telephone", :string
      t.column "description", :text
      t.column "subscription_date", :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
