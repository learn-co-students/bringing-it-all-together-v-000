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
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    dog_creation = Dog.new(name: row[1], breed: row[2], id: row[0])
    dog_creation
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |x|
      self.new_from_db(x)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |x|
      self.new_from_db(x)
    end.first
  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE breed = ?
    SQL

    DB[:conn].execute(sql, breed).map do |x|
      self.new_from_db(x)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    if self.find_by_breed(breed) && self.find_by_name(name)
      self.find_by_breed(breed)
      self.find_by_name(name)
    else
      self.create(name: name, breed: breed)
    end
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
