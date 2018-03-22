require 'pry'

require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed
  attr_reader :id


  def initialize(id:nil, name:, breed:)
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
  end


  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end


  def self.new_from_db(row)
    new_dog = {}
    new_dog[:id]= row[0]
    new_dog[:name] = row[1]
    new_dog[:breed] = row[2]
    dog = self.new(new_dog)
  end


  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end


  def update
    sql = "UPDATE dogs SET name = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.id)
  end


  def self.create(row)
    dog = Dog.new(row)
    dog.save
    dog
  end


  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name)[0]
    dog = {}
    dog[:id] = result[0]
    dog[:name] = result[1]
    dog[:breed] = result[2]
    dog = self.new(dog)
  end


  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    result = DB[:conn].execute(sql, id)[0]

    dog = {}
    dog[:id] = result[0]
    dog[:name] = result[1]
    dog[:breed] = result[2]
    dog = self.new(dog)
  end


  def  self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(dog_data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

end
