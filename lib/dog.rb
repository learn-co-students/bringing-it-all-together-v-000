require 'pry'
class Dog
   
   attr_accessor :id, :name, :breed
   
   def initialize(id: nil, name:, breed:)
       @id, @name, @breed = id, name, breed
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
       DB[:conn].execute("DROP TABLE dogs") 
    end
    
    def self.new_from_db
        
    end
    
    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end
    
    def update
       DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id) 
    end
    
    def self.create(hash)
        Dog.new(hash).save
    end
    
    def self.find_by_id(id)
        doggo = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
        new_from_db(doggo)
    end
    
    def self.new_from_db(row)
        Dog.new({id: row[0], name: row[1], breed: row[2]}).save
    end
    
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        
        dog_array = DB[:conn].execute(sql, name, breed).flatten
        
        dog_array.size == 0 ? self.create(name: name, breed: breed) : self.new_from_db(dog_array)
    end
    
    def self.find_by_name(name)
       sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
       SQL
       
       self.new_from_db(DB[:conn].execute(sql, name).flatten)
    end
    
end