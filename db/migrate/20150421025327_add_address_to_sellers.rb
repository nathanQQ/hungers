class AddAddressToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :address_line1, :string
    add_column :sellers, :address_line2, :string
    add_column :sellers, :city, :string
    add_column :sellers, :state, :string
    add_column :sellers, :zip_code, :string
  end
end
