class Teacher < ApplicationRecord
  belongs_to :subject
  
  has_many :enrollments
  has_many :students, through: :enrollments
end
