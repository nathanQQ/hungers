class AddDeletedAtToListings < ActiveRecord::Migration
  def change
    add_column :listings, :deleted_at, :datetime
    add_index :listings, :deleted_at
  end
end
