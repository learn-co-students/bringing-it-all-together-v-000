require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: name, breed: breed)
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
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name =?, breed =?
    WHERE id =?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(array)
    new_dog = Dog.new(id: array[0], name: array[1], breed: array[2])
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
      WHERE id =?
    SQL

    DB[:conn].execute(sql, id).map { |array| self.new_from_db(array) }.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name =? AND breed =?
    SQL

    if dog = DB[:conn].execute(sql, name, breed).map { |array| self.new_from_db(array) }.first
      dog
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name =?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map { |array| self.new_from_db(array)  }.first
  end
end
