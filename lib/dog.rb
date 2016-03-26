require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader   :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed 
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY AUTOINCREMENT
      , name TEXT
      , breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT LAST_INSERT_ROWID() FROM dogs")[0][0]
    end
  end
 
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog 
  end

  def self.find_by_id(number)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, number)[0]
    dog = Dog.new(id: result[0], name: result[1], breed: result[2])
    dog
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0][0]
      dog = Dog.new_from_db(dog_data)
    else 
      dog = self.create(name: name, breed: breed)
    end
    dog 
  end
 
# .find_or_create_by
# # creates an instance of a dog if it does not already exist 
# when two dogs have the same name and different breed, 
#   it returns the correct dog when creating a new dog with the 
#   same name as persisted dogs, it returns the correct dog  

  def self.new_from_db(ary)  
    dog = Dog.new(id: ary[0], name: ary[1], breed: ary[2])
    dog.save
    dog
  end 

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    results = DB[:conn].execute(sql, name)[0]
    self.new_from_db(results)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
end