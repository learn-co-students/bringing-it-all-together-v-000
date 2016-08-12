require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
attr_accessor :name, :grade, :id


def initialize(id = nil, name, grade)
  @name, @grade, @id = name, grade, id 
end


def self.create_table # creates a table 
  sql = <<-SQL
  CREATE TABLE IF NOT EXISTS students(
  id INTEGER PRIMARY KEY,
  name TEXT,
  grade TEXT
  ) 
  SQL

  DB[:conn].execute(sql)
end

def self.drop_table
  sql = <<-SQL
  DROP TABLE IF EXISTS students
  SQL

  DB[:conn].execute(sql)
end

def save  # saves values of an object into the database
  if self.id
    self.update
  else
    sql = <<-SQL
    INSERT INTO students(name, grade)
    VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end
end

def update # updates database values 
  sql = <<-SQL 
    UPDATE students SET name = ?, grade = ? 
    WHERE id = ? 
  SQL

  DB[:conn].execute(sql, self.name, self.grade, self.id)
end

def self.create(name, grade) # creats objects from what is passed in
student = Student.new(name, grade)
student.save 
student
end

def self.new_from_db(row)
    student = self.new(row[0], row[1], row[2])
    student
end

def self.find_by_name(student_name)
  sql = <<-SQL 
    SELECT * from students 
    WHERE name = ?
  SQL

  DB[:conn].execute(sql, student_name).map do |row|
    self.new_from_db(row)
  end.first
end




end # class 