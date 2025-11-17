class RunProcess
  def self.process
    obj = new
    obj.run
  end

  def run
    run_classes
  end

  private

  def run_classes
    
    subjects_map = PopulateSubjects.process
    teachers_map = PopulateTeachers.process(subjects_map)
    students_map = PopulateStudents.process
    enrollments_map = PopulateEnrollments.process(students_map, teachers_map)
  end
end

