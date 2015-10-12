class AddMorefieldsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :transaction_fee, :integer, :default => 0
    add_column :orders, :collected, :integer, :default => 0
  end
end
