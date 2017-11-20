
require "pry"
class Dog

attr_accessor :name, :breed
attr_reader :id

def initialize(id: nil, name:, breed:)
  @id = id
  @name = name
  @breed = breed
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
  DB[:conn].execute("DROP TABLE IF EXISTS dogs")
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

def self.new_from_db(array)
  'binding.pry'
  new_dog = self.new(id: array[0], name: array[1], breed: array[2])
  new_dog

end

def self.create(hash)
  dog=self.new(hash)
  dog.save
  dog
end

def self.find_by_id(id)
  sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

  new_dog = DB[:conn].execute(sql, id)[0]
  dog = self.new_from_db(new_dog)

  dog
end

def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

  if !dog.empty?
    data = dog[0]
    dog = Dog.new(id: data[0], name: data[1], breed:[2])
  else
    dog=self.create(name: name, breed: breed)
  end
  dog
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? LIMIT 1
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
