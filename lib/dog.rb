class Dog
attr_accessor :name, :breed
attr_reader :id

def initialize(id:nil,name:,breed:)
@id = id
@name = name
@breed = breed
end

def self.create_table
sql = <<-SQL
CREATE TABLE IF NOT EXISTS dogs(
  id INTEGER primary key,
  name TEXT,
  breed TEXT
);
SQL
DB[:conn].execute(sql)
end

def self.drop_table
DB[:conn].execute("DROP TABLE dogs")
end

def save
sql = <<-SQL
INSERT INTO dogs (name,breed)
VALUES (?,?);
SQL
DB[:conn].execute(sql,@name,@breed)
@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
self
end

def self.create(input)
new_dog = self.new(input)
new_dog.save
new_dog
end

def self.find_by_id(id)
sql = <<-SQL
SELECT *
FROM dogs
WHERE id = ?;
SQL
array = DB[:conn].execute(sql,id)[0]
self.new(id:array[0],name:array[1],breed:array[2])
end

def self.find_or_create_by(name:,breed:)
sql = <<-SQL
SELECT *
FROM dogs
WHERE name = ?
AND breed = ?;
SQL

returned_dog = DB[:conn].execute(sql,name,breed)

if !returned_dog.empty?
  return Dog.new(id:returned_dog[0][0],name:returned_dog[0][1],breed:returned_dog[0][2])
else
  self.create(name:name, breed:breed)
end
end

def self.new_from_db(row)
new_dog = Dog.new(id:row[0],name:row[1],breed:row[2])
new_dog
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE name = ?;
  SQL
Dog.new_from_db(DB[:conn].execute(sql,name)[0])
end

def update
sql = <<-SQL
UPDATE dogs
SET name = ?, breed = ?
WHERE id = ?
SQL
DB[:conn].execute(sql,@name,@breed,@id)
end

end
