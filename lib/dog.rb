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
      breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL 
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(database_array)
    Dog.new(id: database_array[0], name: database_array[1],breed: database_array[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL 
        SELECT * FROM dogs WHERE name = ?
    SQL

    new_dog = DB[:conn].execute(sql, name)[0]
    self.new_from_db(new_dog)
  end

  def update
      sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL

      DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL 
        INSERT INTO dogs (name,breed) VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name,self.breed)

      @id =  DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name,breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql,id)[0]
    Dog.new(id: result[0],name: result[1],breed: result[2])
  end

  def self.find_or_create_by(name:, breed:)
    #find in DB where = name. if that is nil then take the [] of it and make a new
    # if nil, then create a new one. 
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? and breed = ?
    SQL

    dog = DB[:conn].execute(sql,name,breed)

    if !dog.empty?
      doggies = dog[0]
      dog = Dog.new(id: doggies[0], name: doggies[1],breed: doggies[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

end