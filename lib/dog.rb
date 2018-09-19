class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: id = nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def attributes
        self.name
        self.breed
    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        attributes.each {|key, value| new_dog.send(("#{key}="), value)}
        new_dog.save
    end

    def self.new_from_db(row)
        new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        new_dog
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
    end

    def self.find_by_id(num)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, num).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


    def save
        if self.id != nil
          self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end
    
    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT);
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

end
