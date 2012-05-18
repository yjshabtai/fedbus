class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.decimal :total
      t.string :status
      t.string :payment
      t.integer :user_id

      t.timestamps
    end
  end
end
