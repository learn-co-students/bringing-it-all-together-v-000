require_relative '../config/environment.rb'

class Dog
  attr_accessor :name, :breed, :id

 def initialize(id: nil, name:, breed:)
   # binding.pry
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
     sql = "INSERT INTO dogs SET name = ?, breed = ?"
     DB[:conn].execute(sql, self.name, self.breed)
   else
     sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
     SQL
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() dogs").flatten[0]
   end
   self # => Return Instance of Song
 end

 # => Check Solution for better code.
 def self.create(attr)
   new_dog = self.new(name: attr[:name], breed: attr[:breed])
   new_dog.save
   new_dog
 end

 def self.find_by_id(id)
   sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    LIMIT 1
   SQL
   dog = DB[:conn].execute(sql, id)
   if !dog.empty?
     dog = dog[0]
     new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
   else
     dog = dog[0]
     new_dog = Dog.create(name: dog[1], breed: dog[2])
   end
   new_dog
 end

 def self.find_or_create_by(attrs)
   sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE name = ? AND breed = ?
     LIMIT 1
   SQL
   dog = DB[:conn].execute(sql, attrs[:name], attrs[:breed])
   if !dog.empty?
     dog = dog[0]
     new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
   else
     new_dog = Dog.create(name: attrs[:name], breed: attrs[:breed])
   end
   new_dog
 end

 def self.new_from_db(row)
   dog = self.new(id: row[0], name: row[1], breed: row[2])
   dog
 end

 def self.find_by_name(name)
   sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    LIMIT 1
   SQL
   dog = DB[:conn].execute(sql, name)
   if !dog.empty?
     dog = dog[0]
     new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
   else
     dog = dog[0]
     new_dog = Dog.create(name: dog[1], breed: dog[2])
   end
   new_dog
 end

 def update
   sql = <<-SQL
    UPDATE dogs
    SET id = ?,
    name = ?,
    breed = ?
   SQL
   DB[:conn].execute(sql, self.id, self.name, self.breed)
 end


end
