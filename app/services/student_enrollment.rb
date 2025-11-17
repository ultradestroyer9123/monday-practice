class StudentEnrollment
	def self.process(student)
		obj = new(student)
		obj.run
	end

	def initialize(student)
		@student = student
    @schedule = []
    @required_subjects = Subject.where(core: true)
    @elective_subjects = Subject.where(core: false)
	end

	def run
		assign_student_to_required_subjects
    assign_student_to_elective_subjects
		@schedule
	end

	private

	def assign_student_to_required_subjects
		@required_subjects.each do |subject|
      assign_student_subject(subject)
    end
	end

  def assign_student_to_elective_subjects
		@elective_subjects.each do |subject|
      assign_student_subject(subject)
    end
	end

  def assign_student_subject(subject)
    # teacher = Teacher.joins(:subject).where(subjects: { name: subject_name}).sample
    teacher = subject.teachers.sample
    @schedule << Enrollment.create(
      student: @student,
      teacher: teacher,
      subject: subject.name,
      period: @schedule.size + 1,
      core: subject.core
    )
  end
end

# StudentEnrollment.process(name: "John Doe", phone: "123-456-7890", email: "john@example.com", grade: "10")