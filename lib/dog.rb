class Dog 
    attr_accessor :name, :id, :breed 

    def initialize(id:nil, name:, breed:)
        @name, @breed, @id = name, breed, id 
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
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end 

    def save 
        if self.id 
            self.update 
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end 
        self
    end
 
    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed) 
        dog.save 
        dog 
    end 
 
    def self.find_by_id(id)
        sql = "SELECT * FROM DOGS WHERE id = ?"
        dog_array = DB[:conn].execute(sql, id)[0]
        new_from_db(dog_array)
    end 

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog =self.new(id:id, name:name, breed:breed)
        new_dog
    end 

    def self.find_or_create_by(name:, breed:) 
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog [0]
            found_dog = new_from_db(dog_data)
        else 
            new_dog = self.create(name: name, breed:breed)
        end 
        found_dog || new_dog
    end 

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?;"
        dog_data = DB[:conn].execute(sql, name)[0]
        new_from_db(dog_data)
    end 

    def update
        sql = "UPDATE dogs SET name = ? , breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id) 
    end 
end 