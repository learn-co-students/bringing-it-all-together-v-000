class Dog 
  
  attr_accessor :name, :breed, :id 
  
  def initialize (name:, breed:, id: nil)
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def save
   if !self.id   
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   else 
    sql = <<-SQL 
       UPDATE dogs SET name = ?, breed = ? WHERE id = ?
       SQL
       
    DB[:conn].execute(sql, self.name, self.breed, self.id)
   end 
   self
   end 
   
   def self.create(name:, breed:) 
    x = Dog.new(name: name, breed: breed)
    x.save 
    x
  end 
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    x = DB[:conn].execute(sql, id).flatten 
    
    y = Dog.new(name: x[1], breed: x[2], id: id) 
    y
  end
  
  def self.find_or_create_by(name:, breed:) 
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end 
  
  def self.new_from_db(row)
    y = Dog.new(name: row[1], breed: row[2], id: row[0]) 
    y 
  end
  
  def self.find_by_name(name) 
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    x = DB[:conn].execute(sql, name).flatten 
    
    y = Dog.new(name: x[1], breed: x[2], id: x[0]) 
    y
  end 
  
  def update 
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)  
    
  end 
end 