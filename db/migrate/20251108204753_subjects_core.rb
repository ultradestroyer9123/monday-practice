class SubjectsCore < ActiveRecord::Migration[8.1]
  def change
    add_column :subjects, :core, :boolean, default: false
  end
end
