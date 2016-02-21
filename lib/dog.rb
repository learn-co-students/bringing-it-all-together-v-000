require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
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
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    if !self.id
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    else
      DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?;", self.name, self.breed, self.id)
    end
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.id = ?;
    SQL

    id = DB[:conn].execute(sql, id)[0][0]
    name = DB[:conn].execute(sql, id)[0][1]
    breed = DB[:conn].execute(sql, id)[0][2]

    attributes = {:name => name, :breed => breed, :id => id}
    self.create(attributes)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.name = ? AND dogs.breed = ?;
    SQL
    row = DB[:conn].execute(sql, name, breed)

    if !row.empty?
      row = row[0]
      attributes = {:name => row[1], :breed => row[2], :id => row[0]}
      self.new(attributes)
    else
      attributes = {:name => name, :breed => breed}
      self.create(attributes)
    end
  end

  def self.new_from_db(row)
    attributes = {:name => row[1], :breed => row[2], :id => row[0]}
    dog = self.create(attributes)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE dogs.name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end


end