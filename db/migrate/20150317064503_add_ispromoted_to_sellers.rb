class AddIspromotedToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :is_promoted, :boolean, :default => 0
  end
end
