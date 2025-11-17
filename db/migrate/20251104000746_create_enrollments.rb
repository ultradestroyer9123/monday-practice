class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: true
      t.string :subject, null: false
      t.integer :period, null: false

      t.timestamps
    end
  end
end
