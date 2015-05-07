class AddIsPickedUpToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_pickedup, :boolean, :default => false
  end
end
