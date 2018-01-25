class Dog
    
    attr_accessor :name, :breed
    attr_reader :id
    
    def initialize(id: nil, name: name, breed: breed)
        @id = id
        @name = name
        @breed = breed
    end
    
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
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
        if self.id
            self.update
        else
          sql = <<-SQL
          INSERT INTO dogs (name, breed) VALUES (?, ?)
          SQL
        
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
    end
    
    def self.create(name:, breed:)  
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        info = DB[:conn].execute(sql, id)[0]
        Dog.new(id: info[0], name: info[1], breed: info[2])
    end
    
    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if dog.empty?
            dog = Dog.create(name: name, breed: breed)
        else
           dog_array = dog[0] 
           dog = Dog.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
       end
       dog
   end
   
   def self.new_from_db(row)
       dog = Dog.new(id: row[0], name: row[1], breed: row[2])
       dog.save
       dog
   end
   
   def self.find_by_name(name)
       sql = <<-SQL
       SELECT * FROM dogs WHERE name = ?
       SQL
       info = DB[:conn].execute(sql, name)[0]
       Dog.new(id: info[0], name: info[1], breed: info[2])
   end
   
   def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    
    DB[:conn].execute(sql,self.name, self.breed, self.id)
  end
end