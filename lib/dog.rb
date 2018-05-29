require 'pry'

class Dog

  attr_accessor :name,  :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql= <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
   end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES
      (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql= <<-SQL
     SELECT *
     FROM dogs
     WHERE id = ?
    SQL
     array = DB[:conn].execute(sql, id)[0]
     new_dog = Dog.new(name: array[1], breed: array[2], id: array[0])
     new_dog
  end

  def self.find_or_create_by(name:, breed:)
   dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
   if !dog.empty?
     dog_data = dog[0]
     new_dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
   else
     created_dog = self.create(name: name, breed: breed)
   end
 end

 def self.new_from_db(row)
  new_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  new_dog
end

def self.find_by_name(name)
  dog =  DB[:conn].execute("SELECT * from dogs WHERE name = ?", name)[0]
    new_dog = Dog.new(name: dog[1], breed: dog[2], id: dog[0])
    new_dog
  end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end





end
