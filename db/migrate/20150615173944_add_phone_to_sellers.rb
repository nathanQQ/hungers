class AddPhoneToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :phone, :string, :default => "1234567890"
  end
end
