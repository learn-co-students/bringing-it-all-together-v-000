require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end
=begin
  def self.new_from_db(row)
    dog_creation = self.new(row[0], row[1], row[2])
    dog_creation
  end
=end
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name, breed)
    new_dog = Dog.new(name, breed)
    binding.pry
    new_dog.save
    new_dog
  end
end
