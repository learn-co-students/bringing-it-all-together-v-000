require_relative "../config/environment.rb"
require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =  <<-SQL
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

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id, name, breed)
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
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
    end
    self
  end

  def self.create(name:, breed:)
    # dog = Dog.new(name, breed) # wrong number of arguments (given 2, expected 0)
    # dog = Dog.new # missing keywords: name, breed
    # dog = Dog.new(name, breed) # wrong number of arguments (given 2, expected 0)
    # dog = Dog.new(name:, breed:) #unexpected ',' (SyntaxError) dog = Dog.new(name:, breed:) # wrong number of ar...
    dog = Dog.new(name:, breed:) # wrong number of ar...
    binding.pry
    # dog.name = name
    # dog.breed = breed
    # dog.name = @name # missing keywords: name, breed
    # dog.breed = @breed
    # dog.name = name:
    # dog.breed = breed: #syntax error, unexpected ':', expecting keyword_end
    dog.save
    dog
  end
end
