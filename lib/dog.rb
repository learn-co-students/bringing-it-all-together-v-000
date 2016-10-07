require "pry"
class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"

        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"

        DB[:conn].execute(sql, name).map { |row| self.new_from_db(row)}.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

        dog = DB[:conn].execute(sql, self.name, self.breed, self.id)
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
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
        DB[:conn].execute(sql, id).map { |row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            self.new_from_db(dog[0])
        else
            self.create(name: name, breed: breed)
        end
    end
end
