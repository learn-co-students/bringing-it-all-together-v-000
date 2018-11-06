class Dog 
  attr_accessor :name, :breed, :id 
  
  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
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
    DROP TAble dogs 
    SQL
    DB[:conn].execute(sql)
  end 
  
  def save
    if self.id == nil 
      sql = <<-SQL 
        INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else 
      self.update 
          end 
    self 
  end 
  
  def self.create(hash)
     new_dog = Dog.new(hash)
     new_dog.save 
  end 
  
  def self.find_by_id(id) 
    sql= <<-SQL 
    Select * from dogs where id = ?
    SQL
    
   data = DB[:conn].execute(sql, id).first 
   hash_for_create = {:name => data[1],
   :breed => data[2]}
   new_dog = self.create(hash_for_create)
   new_dog.id = data[0]
   new_dog
  end 
  
  def self.find_by_name(name)
    sql= <<-SQL 
    Select * from dogs where name = ?
    SQL
    
   data = DB[:conn].execute(sql, name).first 
   new_dog = Dog.new_from_db(data)
   new_dog
  end 
  
  def self.new_from_db(data)
     hash_for_create = {:name => data[1],
   :breed => data[2]}
   new_dog = self.create(hash_for_create)
   new_dog.id = data[0]
   new_dog
  end 

  def self.find_or_create_by(hash)
    dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dogs.empty?
      dog_data = dogs[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(hash)
    end
    dog 
  end 
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  

  
end 