class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.text :message
      t.string :model
      t.integer :source_id
      t.integer :user_id

      t.timestamps
    end
  end
end
