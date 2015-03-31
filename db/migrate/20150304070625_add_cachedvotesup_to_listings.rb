class AddCachedvotesupToListings < ActiveRecord::Migration
  def change
    add_column :listings, :cached_votes_up, :integer
  end
end
