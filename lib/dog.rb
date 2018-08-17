class Dog 
  
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end 
  
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)"
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end 

  def save
    if self.instance_of?(Dog) 
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
    
      @id = DB[:conn].execute("SELECT last_insert_rowid()
      FROM dogs")[0][0]
    end 
    self 
  end 
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end 
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    new_dog = DB[:conn].execute(sql, id)[0]
    new_dog = Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
  end 
  
  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, name, breed)
    if dog.empty?
      new_dog = self.create(name: name, breed: breed)
    else 
      dog_row = dog[0]
      new_dog = Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
    end 
    new_dog 
  end 
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    dog_row = DB[:conn].execute(sql, name)[0]
    new_dog = Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
    new_dog
  end 
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, name, breed, id)
  end 
  
  
  
end 
    