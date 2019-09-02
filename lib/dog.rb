require 'pry'

class Dog 
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name 
    @breed = breed
  end
  
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)"
      DB[:conn].execute(sql)
    end
    
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql,self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(name:, breed:)
    #binding.pry
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    array = DB[:conn].execute(sql, id)[0]
    Dog.new(name: array[1], breed: array[2], id: array[0])
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql,name, breed)
    if !dog.empty?
      data = dog[0]
      #binding.pry
      dog = self.new(name: data[1], breed: data[2], id: data[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def self.new_from_db(row)
    dog = self.new(name: row[1], breed: row[2], id: row[0])
    dog
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    data = DB[:conn].execute(sql, name)[0]
    self.new(name: data[1], breed: data[2], id: data[0])
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end