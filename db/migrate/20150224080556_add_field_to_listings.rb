class AddFieldToListings < ActiveRecord::Migration
  def change
    add_column :listings, :seller_id, :integer
  end
end
