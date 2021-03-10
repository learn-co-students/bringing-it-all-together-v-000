require 'pry'
class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    dog = Dog.new({id: row.flatten[0], name: row.flatten[1], breed: row.flatten[2]})
    dog
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL
    students = DB[:conn].execute(sql)
    students.map do |student|
      self.new_from_db(student)
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    student = DB[:conn].execute(sql, name)
    self.new_from_db(student)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    dog = DB[:conn].execute(sql, id)
    self.new_from_db(dog)
  end

  def self.find_or_create_by(attr_hash)
    values = attr_hash.values
    name = values[0]
    breed = values[1]
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    arr = DB[:conn].execute(sql, name, breed)
    if !arr.empty? #the dog already exists
      return self.new_from_db(arr)
    else
      return self.create({name: name, breed: breed})
    end
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
end
