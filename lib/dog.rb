require 'pry'

class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id 
        @name = name 
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
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
            INSERT INTO dogs(name, breed) VALUES(?, ?)
        SQL
        DB[:conn].execute(sql, @name, @breed)[0]
        @id = DB[:conn].last_insert_row_id
        self
    end

    def self.create(hash)
        self.new(name: hash[:name], breed: hash[:breed]).save
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)[0]
        self.new_from_db(row)
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name)[0]
        self.new_from_db(row)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ?
            WHERE id = ?
        SQL
        a = DB[:conn].execute(sql, @name, @breed, @id, )
    end
    
    def self.find_or_create_by(name:, breed:)
        dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dogs.empty?
            dog_row = dogs[0]
            dog = self.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end
end
