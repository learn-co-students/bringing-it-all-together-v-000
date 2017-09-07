require 'pry'
class Dog
    attr_accessor :id, :name, :breed
   
    
    def initialize (id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed 
    end# of initialize 
    
    
    def self.create_table
        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
        SQL
        
        DB[:conn].execute(sql)
    end# of self.create_table
    
    
    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end# of self.drop_table
    
    
    
    def save
        if self.id
            self.update
        
        else
           sql = <<-SQL
           INSERT INTO dogs (name, breed)
           VALUES (?,?)
           SQL
           
           DB[:conn].execute(sql, self.name, self.breed)
           self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
           self 
        end# of if statement   
    end# of save 
    
    
    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save 
    end# of self.create
    
    
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        row = DB[:conn].execute(sql, id).flatten
        dog = self.new(id: row[0], name: row[1], breed: row[2])
        dog 
    end# of self.find_by_id
    
    def self.find_or_create_by(name:, breed:)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
        
        if (row[1] == name) & (row[2] == breed) 
           self.find_by_id(row[0])

        else
           self.create(name: name, breed: breed)
        end# of if statement

        
    end# of self.find_or_create_by
    
    
    def self.new_from_db(row)
      self.create(name: row[1], breed: row[2])
    end# of self.new_from_db
    

    def self.find_by_name(dog_name)
      sql = ("SELECT * FROM dogs WHERE name = ?")
      dog = DB[:conn].execute(sql, dog_name).flatten
      self.find_by_id(dog[0])
    end# of find_by_name
    
   def update
     sql = <<-SQL 
     UPDATE dogs SET name = ?, breed = ? 
     WHERE id = ?
     SQL
   
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end# of update
   
end# of class 