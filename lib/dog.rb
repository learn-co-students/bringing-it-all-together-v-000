require_relative "../config/environment.rb"
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
     CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    self
  end

  def self.create(hash={})
    #binding.pry
    dog = Dog.new(name:hash[:name],breed:hash[:breed])
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    dog_table = DB[:conn].execute(sql, id)

    dog_table.map do |row|
      Dog.new(id: row[0], name: row[1], breed: row[2])
    end.first
  end

  def self.find_or_create_by(hash={})
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !dog.empty?
      #binding.pry
      dog_object = Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
    else
      dog_object = Dog.create(hash)
    end
    dog_object
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog.save
    dog
  end

  def self.find_by_name(name)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)
    dog_object = Dog.new(id: dog_data[0][0], name: dog_data[0][1], breed: dog_data[0][2])

  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
