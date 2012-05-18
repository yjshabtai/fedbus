class CreateBuses < ActiveRecord::Migration
  def change
    create_table :buses do |t|
      t.string :name
      t.text :description
      t.time :depart_time
      t.time :arrive_time
      t.time :return_time
      t.date :date
      t.decimal :ticket_price
      t.text :comment
      t.string :status
      t.string :direction
      t.integer :sales_lead
      t.integer :maximum_seats
      t.integer :trip_id
      t.integer :destination_id

      t.timestamps
    end
  end
end
