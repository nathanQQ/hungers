class AddNrorderToListings < ActiveRecord::Migration
  def change
    add_column :listings, :nr_order, :integer, :default => 0
  end
end
