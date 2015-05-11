class AddFieldsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :nr_order, :integer, :default => 1
    add_column :orders, :tax, :integer, :default => 0
  end
end
