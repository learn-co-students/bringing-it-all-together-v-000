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
    DB[:conn].execute(sql)
  end

  def self.drop_table
  sql = <<-SQL
    DROP TABLE IF EXISTS dogs
  SQL
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
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  end

  def self.create(name:, breed:)
    dog = self.new(name:name,breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
     SELECT * FROM dogs WHERE id = ?
    SQL
    dog_info = DB[:conn].execute(sql, id)[0]
    self.new(name: dog_info[1],breed: dog_info[2], id: dog_info[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
      dog_data = dog[0]
      new_dog = self.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    end
  end

  def self.new_from_db(row)
    self.new(name:row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL

    dog_info = DB[:conn].execute(sql, name)[0]
    self.new(name: dog_info[1],breed: dog_info[2], id: dog_info[0])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
