class Dog

    attr_accessor :name, :breed
    attr_reader :id


    def initialize(id: nil, name: , breed:)
        @id = id
        @name = name
        @breed = breed
    end



    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT, 
            breed TEXT
        );
        SQL

        DB[:conn].execute(sql)
    end 


    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs 
        SQL

        DB[:conn].execute(sql)
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", @name, @breed)
        @id = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", @name).flatten.first
        self
    end

    def self.create(name:, breed:)
        self.new(name: name, breed: breed).save
    end 

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
       self.all.find{|dog| dog.id == id}
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
        if dog[0] && dog[2] == breed
            self.find_by_id(dog[0])
        else
            self.create(name: name, breed: breed)
        end 
    end 

    def self.all 
        dogs = DB[:conn].execute("SELECT * FROM dogs")
        dogs.collect do |d|
            self.new(id: d[0], name: d[1], breed: d[2])
        end 
    end 
    
    def self.find_by_name(name)

        self.all.find{|dog| dog.name == name}

    end 

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ?", @name, @breed)
    end 
end 