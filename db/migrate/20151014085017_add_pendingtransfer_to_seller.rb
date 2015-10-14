class AddPendingtransferToSeller < ActiveRecord::Migration
  def change
    add_column :sellers, :pending_transfer, :integer, :default => 0
  end
end
