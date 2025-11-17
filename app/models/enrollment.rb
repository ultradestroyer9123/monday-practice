class Enrollment < ApplicationRecord
    belongs_to :student
    belongs_to :teacher

    before_save :set_subject

    private

    def set_subject
        self.subject = teacher.subject.name
    end
end
