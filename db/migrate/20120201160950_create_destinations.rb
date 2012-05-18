class CreateDestinations < ActiveRecord::Migration
  def change
    create_table :destinations do |t|
      t.string :name
      t.text :description
	  t.text :location_description
	  t.string :address

      t.timestamps
    end
  end
end
