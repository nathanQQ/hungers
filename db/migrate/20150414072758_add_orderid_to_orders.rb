class AddOrderidToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_id, :string
  end
end
