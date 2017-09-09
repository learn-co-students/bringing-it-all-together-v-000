class Dog
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:, id:nil)
      @name=name
      @breed=breed
      @id = id
    end
  
    def self.create_table
      sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,  
        name TEXT,  
        breed TEXT)
      SQL
      DB[:conn].execute(sql)   
    end

    def self.drop_table
      DB[:conn].execute("DROP TABLE dogs")   
    end
  
    def save
      sql=<<-SQL
      INSERT INTO dogs(name, breed)
      VALUES(?,?)
      SQL
        DB[:conn].execute(sql, @name, @breed)    
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0] 
    end
     
      def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save 
        new_dog 
      end
      
      def self.find_by_id(id)
        sql =<<-SQL
        SELECT * FROM dogs WHERE id= ? LIMIT 1
        SQL
        row = DB[:conn].execute(sql, id)[0]
        self.new(name:row[1], breed:row[2], id:row[0])
        
      end
      
      def self.find_or_create_by(name:, breed:)
        sql=<<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
        SQL
        result = DB[:conn].execute(sql, name, breed)[0]
        result != nil ? self.find_by_id(result[0]) : self.create(name:name, breed:breed)
           
	    end
      
      def self.new_from_db(row)
        self.new(name:row[1], breed:row[2], id:row[0]) 
      end
      
      def self.find_by_name(name)
        sql=<<-SQL
        SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
        row = DB[:conn].execute(sql, name)[0]
        return self.new(name:row[1], breed:row[2], id:row[0])
      end
      
      def self.update
        sql=<<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id=?
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
        
      end

     
end