class AddFieldToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :name, :string
    add_column :sellers, :aka_name, :string
  end
end
