class Dog

    attr_accessor :id, :name, :breed

    def attributes(id:, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def initialize(id=nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql =  <<-SQL 
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT,
            grade INTEGER
            )
            SQL
        DB[:conn].execute(sql) 
    end
     
    def self.drop_table 
        sql =  <<-SQL 
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
            VALUES (?, ?);
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
        end
    end
    
      def self.create(name, breed)
        dog = Dog.new(name, breed)
        dog.save
        dog
      end
    
      def update
        sql = "UPDATE dogs SET name = ?, grade = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end
    
      def self.new_from_db(row)
        id = row[0]
        name = row[1]
        grade = row[2]
        new_dog = self.new(id, name, breed)
        new_dog
      end  
    
      def self.find_by_id(id)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          LIMIT 1
        SQL
     
        DB[:conn].execute(sql, id).map do |row|
          self.new_from_db(row)
        end.first
      end  

      def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM songs WHERE name = ? AND album = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end 

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
end
