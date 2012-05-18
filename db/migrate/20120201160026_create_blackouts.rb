class CreateBlackouts < ActiveRecord::Migration
  def change
    create_table :blackouts do |t|
      t.string :comment
      t.date :start
      t.date :expiry

      t.timestamps
    end
  end
end
