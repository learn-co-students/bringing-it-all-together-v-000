class Dog 
  
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name: , breed:  )
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
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
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
     SQL
     
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     self
   end
 end
 
  
 
 def self.create( name: , breed: )
   dog = Dog.new(breed: breed, name: name)
   dog.save
   dog
 end
   
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERe id = ?
    SQL
    
   row = DB[:conn].execute(sql, id)[0]
   dog = Dog.new(id: row[0] ,name: row[1], breed: row[2])
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
  
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_data = dog[0]
      # binding.pry
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      dog
    else
      dog = Dog.new(name: name, breed: breed )
      dog.save
    end
  end
  
  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end
    
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
    SQL
    
    row = DB[:conn].execute(sql, name)
    if !row.empty?
      dog_data = row[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      dog
    end
  end
  
  def update
    # id = self.id
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end