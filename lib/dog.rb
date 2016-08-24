require 'pry'

class Dog

attr_accessor :name, :breed, :id

def initialize(hash)
  @name = hash[:name]
  @breed = hash[:breed]
  @id = nil
end

def self.create_table
  sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);
      SQL

    DB[:conn].execute(sql)
end

def self.drop_table
  sql = "DROP TABLE IF EXISTS dogs"
  DB[:conn].execute(sql)
end

def save
  sql =  <<-SQL
  INSERT INTO dogs (name,breed) VALUES (?,?)
    SQL

  if !self.id
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
end

def self.create(hash)
  new_dog = Dog.new(hash)
  new_dog.save
end

def self.find_by_id(id)

  sql = "SELECT * FROM dogs WHERE id = ?"
  results = DB[:conn].execute(sql, id)[0]

  results_hash = Hash.new
  results_hash[:id] = results[0]
  results_hash[:name] = results[1]
  results_hash[:breed] = results[2]

  new_dog = Dog.new(results_hash)
  new_dog.id = results[0]
  new_dog
end

def self.find_or_create_by(hash)
  sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"

  check = DB[:conn].execute(sql, hash[:name], hash[:breed])

  if check.empty? || check == nil
    this_dog = self.create(hash)
    this_dog
  else
    this_dog_info = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
    this_dog = self.find_by_id(this_dog_info[0])
  end
    this_dog
  end

def self.new_from_db(row)
  value_pairs = {:name => "#{row[1]}", :breed => "#{row[2]}"}
  new_dog = Dog.new(value_pairs)
  new_dog.id = row[0]
  new_dog
end

def self.find_by_name(name)
  sql = "SELECT * FROM dogs WHERE name = ?"
  data = DB[:conn].execute(sql,name)[0]
  self.new_from_db(data)
end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end


end
