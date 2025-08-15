class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :alpha2_code
      t.string :alpha3_code
      t.string :latitude
      t.string :longitude
      t.string :official_name
      t.string :capital
      t.string :region
      t.string :subregion
      t.string :population
      t.string :area
      t.string :currencies
      t.string :language
      t.string :calling_code
      t.string :time_zones
      t.string :borders
      t.string :flag
      t.string :slug

      t.timestamps
    end
  end
end
