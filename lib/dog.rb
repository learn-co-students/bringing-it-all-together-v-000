class Dog

attr_accessor :name, :breed, :id


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
  );
  SQL

  DB[:conn].execute(sql)
end

def self.drop_table
  sql = <<-SQL
  DROP TABLE IF EXISTS dogs
  SQL

  DB[:conn].execute(sql)
end

def save
  if self.id
    self.update
  else

  sql = <<-SQL
  INSERT INTO dogs(name, breed)
  VALUES (?,?);
  SQL

  DB[:conn].execute(sql, self.name, self.breed)
  self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
end
self
end

def self.create(dog_hash)
  new_dog = Dog.new(dog_hash)
  id, name, breed = dog_hash[:id], dog_hash[:name], dog_hash[:breed]
  new_dog.save
  new_dog
end

def self.find_by_id(id)
  sql = <<-SQL
  SELECT * FROM dogs
  WHERE id = ?
  SQL

  DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
  end.first
end

def self.find_or_create_by(name:, breed:)
  finding_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if !finding_dog.empty?
    dog_data = finding_dog[0]
    dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  else
    dog = self.create(name: name, breed: breed)
  end
  dog
end

def self.new_from_db(row)
  Dog.new(id: row[0], name: row[1], breed: row[2])
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM dogs
  WHERE name = ?;
  SQL

  DB[:conn].execute(sql, name).map do |row|
  self.new_from_db(row)
  end.first
end

def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)

end




end
