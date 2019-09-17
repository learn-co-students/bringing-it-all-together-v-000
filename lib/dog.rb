class Dog 
attr_accessor :name, :breed, :id

    def initialize(attr_hash)
        attr_hash.each {|k, v| self.send(("#{k}="), v)}
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
        sql = ("DROP TABLE dogs")
        DB[:conn].execute(sql)
    end

    def save
        sql = ("INSERT INTO dogs (name, breed) VALUES (?, ?)")
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attr_hash)
        dog = Dog.new(attr_hash)
        dog.save
        dog
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = ("SELECT * FROM dogs WHERE name = ?")
        DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
    end

    def self.find_by_id(id)
        sql = ("SELECT * FROM dogs WHERE id = ?")
        DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(attr_hash)
        sql = ("SELECT * FROM dogs WHERE name = ? AND breed = ?")
        row = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])[0]
        row != nil ? new_from_db(row) : self.create(attr_hash)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end