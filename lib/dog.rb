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
      @id = DB[:conn].execute("Select last_insert_rowid() FROM dogs")[0][0]
    end
     self
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end


  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog = DB[:conn].execute(sql,id)[0]
  #  find_dog = [name:dog[1],breed:dog[2],id:dog[0]]
    Dog.new(id: dog[0], name: dog[1], breed: dog[2])
  end

  def self.new_from_db(row)
    dog = Dog.new(name:row[1],breed:row[2],id:row[0])
    dog.save
    dog
  end

  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(name:dog_data[1],breed:dog_data[2],id:dog_data[0])
    else
      dog = self.create(name:@name,breed:@breed)
    end
    dog
  end


    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ?"
      dog = DB[:conn].execute(sql,name).flatten
     find_dog = [name:dog[1],breed:dog[2],id:dog[0]]
      Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    end
end
