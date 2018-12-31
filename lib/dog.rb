
class Dog 
  attr_accessor :id, :name, :breed
  
   def initialize(id:nil, name:, breed:)
     @id = id
     @name = name
     @breed = breed
   end
  
  def self.create_table
     sql =  <<-SQL 
       CREATE TABLE dogs (
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
  
  # I am bad... but why?
  def self.new_from_db(row)
    new_pup = self.new(row[0], row[1], row[2])
    end 
    
    
  # I am bad  
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
  
  def self.create(name:, breed:)
    doggy = Dog.new(name: name, breed: breed)
    doggy.save
    doggy
    end 
  
  # I am bad too 
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, id).collect do |row|
      self.new_from_db(row)
      end.first
      
    end
  
  # I am bad  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
      end.first
    end
  
  def self.find_or_create_by(name, breed)
    end 
  
  
end 