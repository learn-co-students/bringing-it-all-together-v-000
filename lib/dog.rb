require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def self.create(name: name , breed: breed)
   # binding.pry
    dog = Dog.new(name: name , breed: breed)
    dog.save
    dog
  end

    def self.new_from_db(row)  #creates a new Ruby object for each row
    # binding.pry
    dog = self.new(id: @id, name: @name, breed: @breed)
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
    # create a new Student object given a row from the database
  end

  def self.find_by_id(id)
    #binding.pry
    #dog = Dog.create(name: name, breed: breed)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ? LIMIT 1
SQL
    DB[:conn].execute(sql, id).map do |row|
     # binding.pry
      self.new_from_db(id)
       # name_dog = [row[1], row[2]]

    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name: , breed:)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      #binding.pry
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2]) #not an array
      #dog.id = 1
    else
      dog = self.create(name: name, breed: breed) #@id = nil
    end
    dog
  end

  def self.find_by_name(name)
    #binding.pry
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end


end