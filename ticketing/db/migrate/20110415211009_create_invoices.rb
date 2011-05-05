class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.decimal :total
      t.string :status
      t.string :payment

      t.timestamps
    end

		# Invoices-Tickets join table
		create_table :invoices_tickets, :id => false do |t|
			t.integer :invoice_id
			t.integer :ticket_id
		end
  end

  def self.down
    drop_table :invoices
		drop_table :invoices_tickets
  end
end
