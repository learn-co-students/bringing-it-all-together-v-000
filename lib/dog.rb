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

end
