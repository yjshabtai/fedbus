class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :name
      t.integer :destination_id
      t.integer :weekday
      t.time :depart_time
      t.time :arrive_time
      t.time :return_time
      t.decimal :ticket_price
      t.integer :sales_lead
      t.text :comment

      t.timestamps
    end
  end
end
