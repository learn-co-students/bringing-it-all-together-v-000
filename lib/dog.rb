class Dog
    attr_accessor :name, :breed
    attr_reader :id
    def initialize(id: id=nil, name: name, breed: breed)
        @id, @name, @breed = id, name, breed
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES(?, ?)"
            DB[:conn].execute(sql, name, breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.last
            self
        end
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        data = DB[:conn].execute(sql, name).flatten

        self.new_from_db(data)
    end

    def self.find_by_id(id)
        data = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
        self.new_from_db(data)
    end

    def self.new_from_db(data)
        self.new(id: data[0], name: data[1], breed: data[2])
    end

    def self.create(hash)
        self.new.tap do |instance|
            hash.each do |key,value|
                instance.send("#{key}=", value)
            end
            instance.save
        end
    end

    def self.find_or_create_by(name:, breed:)
        data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten!
        if data != nil
            self.new_from_db(data)
        else
            instance = self.new(name: name, breed: breed)
            instance.save
        end
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end
end