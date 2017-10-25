require 'pry'
require_relative "../config/environment.rb"

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.new_from_hash(hash)
    dog = Dog.new(name: nil, breed: nil)
    hash.each do |attribute, value|
      dog.send("#{attribute}=", value)
    end
    dog
  end

  def self.create(hash)
    dog = new_from_hash(hash)
    dog.save
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

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
  end

  def save
    insert
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE breed = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,breed).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(dog_hash)
    if find_by_name(dog_hash[:name]) && find_by_breed(dog_hash[:breed])
      find_by_name(dog_hash[:name])
    else
      create(dog_hash)
    end
  end
end
