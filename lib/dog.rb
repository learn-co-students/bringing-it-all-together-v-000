require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

def initialize(name:, breed:, id:nil)
  @name = name
  @breed = breed
  @id = id
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
  DB[:conn].execute("DROP TABLE dogs")
end

def self.new_from_db(row) #returns an array representing doggo data
  new_dog = Dog.new(name: row[1], id: row[0], breed: row[2])
  new_dog
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
  SQL
  DB[:conn].execute(sql, name).map do |dog|
    new_from_db(dog)
  end.first
end

def save
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  self
end

def update
  sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
  SQL
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def self.create(dog_hash)
  new_dog = Dog.new(name: dog_hash[:name], breed: dog_hash[:breed])
  new_dog.save
  new_dog
end

def self.find_by_id(id)
  sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
  SQL
  DB[:conn].execute(sql, id).map do |dog|
    new_from_db(dog)
  end.first
end

def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND  breed = ?", name, breed)
  dog_data = dog[0]
  if !dog.empty? #if there are no dog values, find dog that corresponds to those values
    new_dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
  else #i
    dog_hash = {name: name, breed: breed}
    new_dog = Dog.create(dog_hash)
  end
  new_dog
end

end #CLASS END
