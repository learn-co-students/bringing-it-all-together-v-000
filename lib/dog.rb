require 'pry'

class Dog
attr_accessor :name, :breed
attr_reader :id

def initialize(name:, breed:, id: nil)
  @id = id
  @name = name
  @breed = breed
end

def self.create_table
  sql =<<-SQL
  CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
  )
  SQL
  DB[:conn].execute(sql)

end

def self.drop_table
  sql = "DROP TABLE dogs"
  DB[:conn].execute(sql)
end

def self.create (hash)
  dog = Dog.new(hash)
  dog.save
end

def self.find_by_id (id)
  sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
  DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
  end.first
end

def self.find_or_create_by(name:, breed:)
  dog_found = find_by_name_breed(name, breed)
  
  if dog_found==nil
    self.create(name: name, breed: breed)
  else
    dog_found
  end
end

def self.new_from_db(row)
  new_dog = self.new(name: row[1], breed: row[2], id: row[0])
end

def self.find_by_name (name)
  sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
  DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
  end.first
end

def self.find_by_name_breed (name, breed)
  sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
  DB[:conn].execute(sql, name, breed).map do |row|
    self.new_from_db(row)
  end.first
end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def save
  sql = <<-SQL
  INSERT INTO dogs (name, breed)
  VALUES(?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end

end
