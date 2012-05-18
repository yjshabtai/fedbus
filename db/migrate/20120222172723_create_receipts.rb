class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.string :transaction_id
      t.string :trace_number
      t.string :approval_code
      t.string :transaction_date
      t.string :hostensoln_id
      t.integer :response_code
      t.string :card_number
      t.integer :invoice_id

      t.timestamps
    end
  end
end
