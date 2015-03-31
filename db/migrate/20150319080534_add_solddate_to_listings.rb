class AddSolddateToListings < ActiveRecord::Migration
  def change
    add_column :listings, :sold_date, :date
  end
end
