require_relative "../config/environment.rb"
require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql1 = "DROP TABLE IF EXISTS dogs"

    sql2 = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql1)
    DB[:conn].execute(sql2)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

# Dog ::create takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end
# **`::new_from_db`**
# This is an interesting method. Ultimately, the database is going to return an array representing a dog's data.
# We need a way to cast that data into the appropriate attributes of a dog. This method encapsulates that
# functionality. You can even think of it as  `new_from_array`. Methods like this, that return instances of the
# class, are known as constructors, just like `::new`, except that they extend the functionality of `::new`
# without overwriting `initialize`.
  def self.new_from_db(row)
    new_dog = self.new(id: row[0],name: row[1],breed: row[2])
    new_dog
  end
# **`::find_by_name`**
# This spec will first insert a dog into the database and then attempt to find it by calling the find_by_name method. The expectations are that an instance of the dog class that has all the properties of a dog is returned, not primitive data.
# Internally, what will the `find_by_name` method do to find a dog; which SQL statement must it run? Additionally,
# what method might `find_by_name` use internally to quickly take a row and create an instance to represent that
# data?
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

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
# **`#update`**
# This spec will create and insert a dog, and after, it will change the name of the dog instance and call update.
# The expectations are that after this operation, there is no dog left in the database with the old name. If we
# query the database for a dog with the new name, we should find that dog and the ID of that dog should be the
# same as the original, signifying this is the same dog, they just changed their name.
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

  def self.find_or_create_by(name: name, breed: breed)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new(id: dog_data[0],name: dog_data[1],breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end
