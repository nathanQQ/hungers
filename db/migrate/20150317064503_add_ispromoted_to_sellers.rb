class AddIspromotedToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :is_promoted, :boolean, :default => false
  end
end
