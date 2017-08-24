class Dog

attr_accessor :name, :breed, :id

def initialize(name:, breed:, id: nil)
  @name = name
  @breed = breed
  @id = id
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
    INSERT INTO dogs(name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
end

def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
end

def self.find_by_id(id)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE id = ?
  SQL

  DB[:conn].execute(sql, id).map do |doggy|
      self.new_from_db(doggy)
    end.first
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE name = ?
  SQL

  DB[:conn].execute(sql, name).map do |doggy|
      self.new_from_db(doggy)
    end.first
end

def self.new_from_db(row)
  from_db = self.new(id: row[0], name: row[1], breed: row[2])
  from_db
end

def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if !dog.empty?
    new_doggy = dog[0]
    dog = Dog.new(id: new_doggy[0], name: new_doggy[1], breed: new_doggy[2])
  else
    dog = self.create(name: name, breed: breed)
  end
  dog
end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

end
