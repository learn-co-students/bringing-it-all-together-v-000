require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id_num)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
     found_dog = DB[:conn].execute(sql, id_num).flatten
     dog = Dog.new(name: found_dog[1], breed: found_dog[2])
     dog.id = found_dog[0]
     dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(name: dog_info[1], breed: dog_info[2])
      dog.id = dog_info[0]
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}'")
    dog_info = dog[0]
    dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

end
