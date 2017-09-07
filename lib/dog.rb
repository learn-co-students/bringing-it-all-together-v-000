require 'pry'

class Dog

attr_accessor :name, :breed, :id

def initialize(id:nil,name:,breed:)
  @name = name
  @breed = breed
  @id = id
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
  sql =  <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
  DB[:conn].execute(sql)
end

def save #updates existing dog row or adds new dog row to database
  if self.id
    self.update
  else
    sql =  <<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?,?)
      SQL
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  self
end

def self.create(name:,breed:) #adds new Dog to database and returns Dog object
  dog = Dog.new(name:name,breed:breed)
  dog.save
  dog
end

def self.find_by_id(id)
  sql = "SELECT * FROM dogs WHERE id = ?"
  dog_array = DB[:conn].execute(sql,id)[0]
  dog = Dog.new(id:dog_array[0],name:dog_array[1],breed:dog_array[2])
  dog
end

def self.find_or_create_by(name:,breed:)
  sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
  dog_array = DB[:conn].execute(sql,name,breed)[0]
  if dog_array == nil #no match found, save a new dog to database, return dog object
    dog = Dog.create(name:name,breed:breed)
  else #match found, insantiate new dog object from array, return dog object
    dog = Dog.new(id:dog_array[0],name:dog_array[1],breed:dog_array[2])
  end
  dog
end

def self.new_from_db(db_row) #intantiates new Dog instance from array
  dog = Dog.new(id:db_row[0],name:db_row[1],breed:db_row[2])
  dog
end

def self.find_by_name(name)
  sql = "SELECT * FROM dogs WHERE name = ?"
  match_from_db = DB[:conn].execute(sql,name)
  dog = Dog.new_from_db(match_from_db[0])
  dog
end

def update
  sql = "UPDATE dogs SET name =?,breed = ? WHERE id = ?"
  DB[:conn].execute(sql,self.name,self.breed,self.id)
end

end
