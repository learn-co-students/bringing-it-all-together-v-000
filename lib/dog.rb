require_relative "../config/environment.rb"
require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    if attributes[:id]
      @id = attributes[:id]
    else
      @id = nil
    end
  end

  def self.new_from_db(row)
    attributes = {}
    attributes[:id] = row[0]
    attributes[:name] = row[1]
    attributes[:breed] = row[2]
    Dog.new(attributes)
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL

    DB[:conn].execute(sql).collect do |row|
      Dog.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).collect do |row|
      #binding.pry
      Dog.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).collect do |row|
      #binding.pry
      Dog.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
      LIMIT 1
    SQL

    dog_data = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).flatten
    dog = Dog.new_from_db(dog_data)
    #binding.pry

    if dog.id
      Dog.find_by_id(dog.id)
    else
      dog.save
    end
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      update
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
end
