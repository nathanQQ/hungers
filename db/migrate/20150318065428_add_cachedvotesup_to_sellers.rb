class AddCachedvotesupToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :cached_votes_up, :integer
  end
end
