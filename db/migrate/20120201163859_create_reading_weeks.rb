class CreateReadingWeeks < ActiveRecord::Migration
  def change
    create_table :reading_weeks do |t|
      t.date :start_date
      t.date :end_date
      t.text :comment

      t.timestamps
    end
  end
end
