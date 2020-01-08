class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
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
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
        dog
    end

    def self.new_from_db(row)
        new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)
        self.new_from_db(row.flatten)
    end

    def self.find_or_create_by(name:, breed:)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !row.empty?
            dog =  self.new_from_db(row.flatten)
        else
            dog = self.create({:name => name, :breed => breed})
        end
        dog
    end
        
    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name)
        self.new_from_db(row.flatten)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? where id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end

