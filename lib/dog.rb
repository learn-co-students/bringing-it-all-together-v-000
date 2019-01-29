require 'pry'

class Dog
  attr_accessor :name, :breed, :id
  
  @@all = []
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed 
    @id = id
    @@all << self
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2])
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog #=> returns an instance of a dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name)[0]
    binding.pry
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
  
    result = DB[:conn].execute(sql, id)[0]
  end
  
  # def self.create(name:, breed:)
  #   binding.pry
  # end
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
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
  end
end