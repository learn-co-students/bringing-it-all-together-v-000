require_relative '../config/environment.rb'

require 'sqlite3'

DB = {conn: SQLite3::Database.new("database.db")}

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? limit 1"
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? limit 1"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  def self.create(name:, breed:)
    pupster = Dog.new(name: name, breed: breed)
    pupster.save
  end
  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      data = dog[0]
      dog = Dog.new(id: data[0], name: data[1], breed: data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end
