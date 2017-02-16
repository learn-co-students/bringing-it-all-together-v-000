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
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT LAST_INSERT_ROWID();")[0][0]
    self
  end

  def self.create(name:, breed:, id: nil)
    new_dog = Dog.new(name: name, breed: breed, id: id)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    dog_array = DB[:conn].execute(sql, id).flatten
    dog_hash = {
      id: dog_array[0],
      name: dog_array[1],
      breed: dog_array[2]
    }
    self.new(dog_hash)
  end

  def self.find_or_create_by(dog_hash)
    name = dog_hash[:name]
    breed = dog_hash[:breed]

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    matches = DB[:conn].execute(sql, name, breed).flatten

    if matches.empty?
      new_dog = self.new(name: name, breed: breed)
      new_dog.save
    else
      new_from_db(matches)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    new_dog = DB[:conn].execute(sql, name).flatten
    new_from_db(new_dog)
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def update
  sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE ID = ?
  SQL

  DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
