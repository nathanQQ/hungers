class AddRecipientToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :recipient, :string
  end
end
