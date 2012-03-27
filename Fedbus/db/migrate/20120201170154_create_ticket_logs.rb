class CreateTicketLogs < ActiveRecord::Migration
  def change
    create_table :ticket_logs do |t|
      t.string :log
      t.integer :user_id
      t.integer :ticket_id

      t.timestamps
    end
  end
end
