class AddCityStateZipcodeColumnsToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :city,    :string
    add_column :locations, :state,   :string
    add_column :locations, :zipcode, :integer
  end
end
