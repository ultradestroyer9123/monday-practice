class AddPulseIdToEnrollmentModel < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :pulse_id, :bigint
    add_index :enrollments, :pulse_id, unique: true
  end
end
