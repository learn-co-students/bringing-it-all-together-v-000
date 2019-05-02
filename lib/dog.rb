require 'pry'
class Dog

attr_accessor :name, :breed
attr_reader :id

def initialize(id:nil, name:, breed:)
  @id = id
  @name = name
  @breed = breed
end

def self.create_table
  sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)"

  DB[:conn].execute(sql)
end

def self.drop_table
  sql = "DROP TABLE IF EXISTS dogs"
  DB[:conn].execute(sql)
end

def self.new_from_db(attr)
  dog = self.new(id:attr[0], name:attr[1], breed:attr[2])
  dog
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    LIMIT 1
  SQL

  row = DB[:conn].execute(sql, name).first
  self.new_from_db(row)
end

def self.create(hash)
  dog = self.new(hash)
  dog.save
  dog

end

def update
  sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
  SQL

  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def save
  if self.id
    self.update
    return self
  else
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    dog = DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    return self
  end
end

def self.find_by_id(id)
  sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    LIMIT 1
  SQL

  row = DB[:conn].execute(sql, id).first
  self.new_from_db(row.flatten)
end

def self.find_or_create_by(hash)
sql = <<-SQL
    SELECT * FROM dogs
    WHERE  name = ? AND breed = ?
    LIMIT 1
    SQL
  found = DB[:conn].execute(sql,hash[:name], hash[:breed])
   if found.empty?
      self.create(hash)
    else
      self.find_by_id(found[0][0])
    end
end

end
