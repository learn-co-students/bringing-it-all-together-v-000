
class Dog
attr_accessor :id, :name, :breed
@@all = []
def initialize(id: nil, name:, breed:)
  @id = id
  @name = name
  @breed = breed
  @@all << self
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
  DROP TABLE IF EXISTS dogs
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
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
end

def self.create(name:, breed:)
  dog = self.new(name: name, breed: breed)
  dog.save
end

#I am curious as to why the solution uses new_from_db in place of something similar to what I did on line 61+
def self.find_by_id(num)
  matched_dog = nil
  sql = <<-SQL
  SELECT * FROM dogs WHERE id = ?
  SQL
  db_return = DB[:conn].execute(sql, num)[0]
  @@all.each do |dog|
    if dog.id == db_return[0]
      matched_dog = dog
    end
  end
  matched_dog
end

def self.find_by_name(name_txt)
  matched_dog = nil
  sql = <<-SQL
  SELECT * FROM dogs WHERE name = ?
  SQL
  db_return = DB[:conn].execute(sql, name_txt)[0]
  @@all.each do |dog|
    if dog.name == db_return[1]
      matched_dog = dog
    end
  end
  matched_dog
end

#I want to understand the arguments in this methos more i.e. name:
def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if dog.empty?
    dog = self.create(name: name, breed: breed)
  else
    dog_data = dog[0]
    self.find_by_id(dog_data[0])
  end
end

def self.new_from_db(row)
  id = row[0]
  name = row[1]
  breed = row[2]
  self.new(id: id, name: name, breed: breed)
end



end
