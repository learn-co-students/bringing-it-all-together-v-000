require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  @@all = []

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
    @@all << self
end

def self.create_table
  sql =  <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
  SQL
  DB[:conn].execute(sql)
end

def self.drop_table
  DB[:conn].execute("DROP TABLE dogs")
end

def save
  sql =<<-SQL
  INSERT INTO dogs (name, breed)
  VALUES (?,?)
  SQL
  DB[:conn].execute(sql, self.name, self.breed)
  self.id = DB[:conn].execute("SELECT MAX(id) FROM dogs")[0][0]
  self
end

def self.create(hash)
  new_dog = new(hash)
  new_dog.save
end

def self.find_by_id(id)
  sql =<<-SQL
  SELECT * FROM dogs
  WHERE id = ?
  SQL
  row = DB[:conn].execute(sql, id)[0]
  self.new_from_db(row)
end

def self.find_or_create_by(hash)
   @@all.detect{|dog| dog.name == hash[:name] && dog.breed == hash[:breed]} || self.create(hash)
end

def self.new_from_db(row)
  hash = {name: row[1], breed: row[2], id: row[0]}
  new(hash)
end

def self.find_by_name(name)
  sql =<<-SQL
  SELECT * FROM dogs
  WHERE name = ?
  SQL
  row = DB[:conn].execute(sql, name)[0]
  @@all.detect{|dog| dog.name == row[1] && dog.id == row[0]}
end

def update
  sql =<<-SQL
  UPDATE dogs
  SET name = ?
  WHERE id = ?
  SQL
  DB[:conn].execute(sql, self.name, self.id)
  sql =<<-SQL
  UPDATE dogs
  SET breed = ?
  WHERE id = ?
  SQL
  DB[:conn].execute(sql, self.breed, self.id)

end

end
