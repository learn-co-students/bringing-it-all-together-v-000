# require_relative '../config/environment.rb'
require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id=nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    sql =  <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs;"
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
  end

  def self.create(hash)
    dog = Dog.new(name: hash[:name], breed: hash[:breed])
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(result[0], name: result[1], breed: result[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_instance = dog[0]
      dog = Dog.new(dog_instance[0], name: dog_instance[1], breed: dog_instance[2])
    else
      dog = self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]

    dog = Dog.new(id, name: name, breed: breed)
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    dog = Dog.new(result[0], name: result[1], breed: result[2])
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
