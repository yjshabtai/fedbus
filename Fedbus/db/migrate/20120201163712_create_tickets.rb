class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :direction
      t.integer :bus_id
      t.integer :user_id
	    t.integer :invoice_id
      t.string :status
      t.decimal :ticket_price

      t.timestamps
    end
  end
end
