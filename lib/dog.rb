class Dog
   attr_accessor :name, :breed
   attr_reader :id
   
   def initialize(attributes, id = nil)
       @name = attributes[:name]
       @breed = attributes[:breed]
       @id = id
   end
   
   def self.create_table
       sql = <<-SQL
       CREATE TABLE IF NOT EXISTS
       dogs(
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
       sql = <<-SQL
       INSERT INTO
       dogs (name, breed)
       VALUES (?, ?)
       SQL
       
       DB[:conn].execute(sql, @name, @breed)
       @id = DB[:conn].execute("SELECT id FROM dogs where name = ? AND breed = ?", @name, @breed)[0][0]
       self
    end 
    
    def self.new_from_db(row)
        row_hash = {
            id: row[0],
            name: row[1],
            breed: row[2]
        }
        
        dog = self.new(row_hash, row[0])
    end
    
    def self.create(hash)
        dog = self.new(hash, hash[:id])
        dog.save
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
        
        doc = new_from_db(DB[:conn].execute(sql, id)[0])
    end
   
   def self.find_or_create_by(hash)
       sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE name = ? AND breed = ?
       SQL
       
       dog = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
       if !dog == nil
           new_from_db(dog)
       else
           create(hash)
       end
   end
   
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL
        
        new_from_db(DB[:conn].execute(sql, name)[0])
    end
    
    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        
        DB[:conn].execute(sql, @name, @breed, @id)
    end
    
end