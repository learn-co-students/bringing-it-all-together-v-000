require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
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
    if self.id
      self.update
    else sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
    
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0],name: row[1],breed: row[2])
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    
    Dog.new_from_db(DB[:conn].execute(sql, name)[0])
  end
  
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    
    Dog.new_from_db(DB[:conn].execute(sql, id)[0])
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    
    search = DB[:conn].execute(sql, name, breed)
    if search.empty?
      dog = self.create(name: name, breed: breed)
    else
      dog = self.new_from_db(search[0])
    end
    dog
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