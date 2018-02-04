require_relative '../config/environment.rb'

require 'pry'

class Dog
  attr_accessor :name, :breed, :id

def initialize(dog)
    @name = dog[:name]
    @breed = dog[:breed]
    @id = nil
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
    if self.id != nil
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    dog = {}
    dog[:name] = row[1]
    dog[:breed] = row[2]
    new_dog = self.new(dog)
    new_dog.id = row[0]
    new_dog
  end

def self.new_from_db(row)
    dog_hash = {}
    dog_hash[:name] = row[1]
    dog_hash[:breed] = row[2]
    dog = self.new(dog_hash)
    dog.id = row[0]
    dog
end

def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0]
    self.new_from_db(row)
end

def self.find_or_create_by(dog_hash)
    name = dog_hash[:name]
    breed = dog_hash[:breed]
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if dog
      dog = self.new_from_db(dog)
    else
    dog = self.create(dog_hash)
  end
  dog
end

def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
