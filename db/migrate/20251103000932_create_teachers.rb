class CreateTeachers < ActiveRecord::Migration[8.1]
  def change
    create_table :teachers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end
