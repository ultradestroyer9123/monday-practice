# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

math = Subject.create(name: "Math", core: true)
science = Subject.create(name: "Science", core: true)
history = Subject.create(name: "History", core: true)
english = Subject.create(name: "English", core: true)
pe = Subject.create(name: "PE", core: true)
art = Subject.create(name: "Art", core: false)
music = Subject.create(name: "Music", core: false)

teacher1 = Teacher.create(name: "Mr. Smith", subject: math, email: "smith@example.com", phone: "123-456-7890")
teacher2 = Teacher.create(name: "Ms. Johnson", subject: science, email: "johnson@example.com", phone: "123-456-7890")
teacher3 = Teacher.create(name: "Mrs. Brown", subject: history, email: "brown@example.com", phone: "123-456-7890")
teacher4 = Teacher.create(name: "Mr. Davis", subject: english, email: "davis@example.com", phone: "123-456-7890")
teacher5 = Teacher.create(name: "Mr. White", subject: music, email: "davis@example.com", phone: "123-456-7890")
teacher6 = Teacher.create(name: "Mrs. Danna", subject: art, email: "davis@example.com", phone: "123-456-7890")
teacher7 = Teacher.create(name: "Mrs. Aly", subject: pe, email: "davis@example.com", phone: "123-456-7890")
teacher8 = Teacher.create(name: "Mrs. Slicy", subject: math, email: "smitwfwh@example.com", phone: "123-456-7890")
teacher9 = Teacher.create(name: "Ms. Porky", subject: science, email: "jowefhnson@example.com", phone: "123-456-7890")
teacher10 = Teacher.create(name: "Mrs. Denise", subject: history, email: "bwefrown@example.com", phone: "123-456-7890")
teacher11 = Teacher.create(name: "Mr. Dary", subject: english, email: "davwefweis@example.com", phone: "123-456-7890")
teacher12 = Teacher.create(name: "Mr. Loke", subject: music, email: "davfwefis@example.com", phone: "123-456-7890")
teacher13 = Teacher.create(name: "Mrs. Frerichs", subject: art, email: "dwefavis@example.com", phone: "123-456-7890")
teacher14 = Teacher.create(name: "Mr. Wihne", subject: pe, email: "dwefavis@example.com", phone: "123-456-7890")

student1 = Student.create(name: "Alice", email: "alice@example.com", phone: "123-456-7890")
student2 = Student.create(name: "Bob", email: "bob@example.com", phone: "123-456-7890")

# Enrollment.create(student: student1, teacher: teacher1, period: 1)
# Enrollment.create(student: student1, teacher: teacher2, period: 2)
# Enrollment.create(student: student1, teacher: teacher3, period: 3)
# Enrollment.create(student: student1, teacher: teacher4, period: 4)

# Enrollment.create(student: student2, teacher: teacher4, period: 1)
# Enrollment.create(student: student2, teacher: teacher3, period: 2)
# Enrollment.create(student: student2, teacher: teacher2, period: 3)
# Enrollment.create(student: student2, teacher: teacher1, period: 4)