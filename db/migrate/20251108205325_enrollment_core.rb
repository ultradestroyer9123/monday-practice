class EnrollmentCore < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :core, :boolean, default: false
  end
end
