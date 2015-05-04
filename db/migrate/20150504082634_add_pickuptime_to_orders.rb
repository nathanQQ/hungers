class AddPickuptimeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :pickup_time, :datetime
  end
end
