class AddReturnOfToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :return_of, :int

  end
end
