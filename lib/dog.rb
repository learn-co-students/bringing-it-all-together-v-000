require 'pry'
class Dog
 attr_accessor :id, :name, :breed

 def initialize(id: nil, name:, breed:)
   @id = id
   @name = name
   @breed = breed
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

 def save
   if self.id
     self.update
   else
   sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
   DB[:conn].execute(sql, self.name, self.breed)
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  self
 end

 def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
 end

 def self.create(name:, breed:)
   new_dog = Dog.new(name: name, breed: breed)
   new_dog.save
   new_dog
 end

def self.new_from_db(row)
  id = row[0]
  name = row[1]
  breed = row[2]
  new_dog = Dog.new(id: id, name: name, breed: breed)
  new_dog
end

def self.find_by_id(id)
  sql = <<-SQL
   SELECT *
   FROM dogs
   WHERE id = ?
   LIMIT 1
   SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
  end.first

 end

def self.find_by_name(name)
  sql = <<-SQL
   SELECT *
   FROM dogs
   WHERE name = ?
   LIMIT 1
   SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
 end

 def self.find_or_create_by(dog_hash)
  name = dog_hash[:name]
  breed = dog_hash[:breed]
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE name = ? AND
  breed = ?
  SQL
  result = DB[:conn].execute(sql, name, breed)
   if !result.empty?
       self.find_by_id(result[0][0])
  else
    self.create(dog_hash)
  end
 end

end
