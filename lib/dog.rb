require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(array)
    id = array[0]
    name = array[1]
    breed = array[2]
    Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = name
    LIMIT 1
    SQL

    dog = DB[:conn].execute(sql).flatten
    Dog.new_from_db(dog)
  end

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

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(num)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    dog_info = DB[:conn].execute(sql, num).flatten

    id = dog_info[0]
    name = dog_info[1]
    breed = dog_info[2]
    Dog.new(id: id, name: name, breed: breed)
    # binding.pry
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    dog_values = DB[:conn].execute(sql, name, breed)
  #  binding.pry

    if !dog_values.empty?
     dog_info = dog_values[0]
     dog = Dog.new_from_db(dog_info)
    else
     dog = self.create(name: name, breed: breed)
    end
    dog
    # binding.pry
 end

end
