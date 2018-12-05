class Dog 
  
  attr_accessor :id, :name, :breed 
  
  def initialize (id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end
  
  def self.create_table 
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS dogs 
    (id INTEGER PRIMARY KEY,
    name TEXT, 
    breed TEXT) 
    SQL
    
    DB[:conn].execute(sql) 
  end
  
  def self.drop_table 
    sql =<<-SQL 
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
      
    end
    self
  end
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.create(hash) 
    dog = Dog.new(hash) 
    dog.save 
  end
  
  def self.new_from_db(row)
    dog = Dog.new(row[0], row[1], row[2])
    dog.id = row[0] 
    dog.name = row[1] 
    dog.breed = row[2]
    dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs 
    WHERE id = ?
    SQL
    
    self.new_from_db(DB[:conn].execute(sql, id))
    
  end
  
end