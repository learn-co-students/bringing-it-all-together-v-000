require 'pry'

class Dog
  attr_accessor :id, :name, :breed

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
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end 
  end

  def self.new_from_db(row) #create an instance from a database record as an array
    id = row[0] #since we are creating new instances from the database, every record should have an assigned ID
    name = row[1]
    breed = row[2]
    new_dog = self.new(id: id, name: name, breed: breed)
    new_dog
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed) #instantiate a new dog instance with initialize method
    dog.save #save that dog instance's attributes into the database
    dog #return the just-created dog instance
  end

  def self.find_by_id(idnum) #finding a dog from the database
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
      SQL

    DB[:conn].execute(sql, idnum).map do |row|
      self.new_from_db(row)
    end.first #will return the newly-created instance
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed) #returns an array if the dog
    #exists in the database
    if !dog.empty? #checks the array for elements
      dog_data = dog[0]
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
      SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update #update the database record
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
