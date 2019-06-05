require 'pry'
class Dog
attr_accessor :name, :breed, :id

def initialize(dog_hash)
  @name = dog_hash[:name]
  @breed = dog_hash[:breed]
  @id = dog_hash[:id]
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    hash = {}
    hash[:name] = row[1]
    hash[:breed] = row[2]
    hash[:id] = row[0]
  new_dog = self.new(hash)
  new_dog
  end

  def save
  #  if self.id
  #self.update
#else
  sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
  SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  #end
end

def self.create(hash)
new_dog = self.new(hash)
new_dog.save
new_dog
end

def self.find_by_id(id)

  sql = "SELECT * FROM dogs WHERE id = ?"
  result = DB[:conn].execute(sql, id)[0]
  dog = self.new_from_db(result)
  dog
end

def self.find_or_create_by(hash)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
 if !dog.empty?
   dog_data = dog[0]
  dog = self.new_from_db(dog_data)
 else
   dog = self.create(hash)
 end
dog
end

def self.find_by_name(name)
  sql = "SELECT * FROM dogs WHERE name = ?"
  result = DB[:conn].execute(sql, name)[0]
  dog = self.new_from_db(result)
  dog
end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
DB[:conn].execute(sql, self.name, self.breed, self.id)
end

end
