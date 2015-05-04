class AddTaxRateToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :tax_rate, :decimal
  end
end
