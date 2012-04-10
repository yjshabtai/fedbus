class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.text :message
      t.string :type
      t.int :source_id
      t.int :user_id

      t.timestamps
    end
  end
end
