class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :email
      t.integer :seller_id
      t.integer :buyer_id
      t.integer :listing_id

      t.timestamps
    end
  end
end
