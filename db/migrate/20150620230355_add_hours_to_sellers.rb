class AddHoursToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :weekday_open_at, :string, :default => "11:00 AM"
    add_column :sellers, :weekday_close_at, :string, :default => "9:00 PM"
    add_column :sellers, :saturday_open_at, :string, :default => "11:00 AM"
    add_column :sellers, :saturday_close_at, :string, :default => "9:00 PM"
    add_column :sellers, :sunday_open_at, :string, :default => "11:00 AM"
    add_column :sellers, :sunday_close_at, :string, :default => "9:00 PM"
  end
end
