class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)

            @id = DB[:conn].execute('SELECT last_insert_rowid();').first.first
        end

        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
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
        DB[:conn].execute('DROP TABLE dogs;')
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL

        self.new_from_db(DB[:conn].execute(sql, id).first)
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1;', name, breed)
        
        if !dog.empty?
            dog = Dog.new_from_db(dog.first)
        else
            dog = Dog.create(name: name, breed: breed)
        end

        dog
    end
end