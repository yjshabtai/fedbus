class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.date :date
      t.string :name
      t.text :comment
      t.date :offset_date

      t.timestamps
    end
  end
end
