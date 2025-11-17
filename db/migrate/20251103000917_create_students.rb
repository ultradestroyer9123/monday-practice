class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.string :name, null: false
      t.string :phone
      t.string :email, null: false
      t.string :grade

      t.timestamps
    end
  end
end
