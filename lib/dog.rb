require_relative "../config/environment.rb"
require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def self.create_table
    sql = "
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
  "
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute( "DROP TABLE dogs")
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

  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    found_dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    self.new(id:found_dog[0], name:found_dog[1], breed:found_dog[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog.flatten
      dog = self.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    dog =  self.new(id:row[0], name:row[1], breed:row[2])
    dog
  end

  def self.find_by_name(name)
  	sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
  	DB[:conn].execute(sql, name).map do |row|
  		self.new_from_db(row)
  	end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
