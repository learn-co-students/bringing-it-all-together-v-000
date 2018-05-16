class Dog 
attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)
  @id = id
  @name = name
  @breed = breed
end 

def self.create_table
  sql = <<-SQL
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

def self.new_from_db(db_row)
  new_dog = Dog.new(id: db_row[0], name: db_row[1], breed: db_row[2])
  new_dog
end 

def save 
  if self.id
    self.update 
  else
    sql = <<-SQL 
    INSERT INTO dogs 
    (name, breed) 
    VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, @name, @breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
  end 
  self
end 
  
  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end 
  
  def self.find_by_id(number)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    
    DB[:conn].execute(sql, number).map do |row|
      self.new_from_db(row)
    end.first 
  end 
  
  def self.find_or_create_by(name:, breed:)
    query = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    return_from_db = DB[:conn].execute(query, name, breed)
    
    if return_from_db[0]
      dog = self.new_from_db(return_from_db.flatten)
    else 
      dog = self.find_by_id(return_from_db[0])
      binding.pry
    end
    dog
  end
    
    
  
end 