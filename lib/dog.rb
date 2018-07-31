class Dog

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
                DROP TABLE IF EXISTS dogs;
            SQL
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL 
                SELECT * FROM dogs WHERE name= ?;
            SQL
        info = DB[:conn].execute(sql, name)[0]
        if !info.nil? && info.length > 0
            self.new_from_db(info)
        end
    end

    def self.create(id: nil, name: , breed:)
        d = self.new(id: id, name: name, breed: breed)
        d.save
    end

    def self.find_by_id(id)
        sql = <<-SQL
                SELECT * FROM dogs WHERE id=?;
            SQL
        info = DB[:conn].execute(sql, id)[0]
        if !info.nil? && info.length > 0
            self.new_from_db(info)
        end
    end

    def self.find_or_create_by(name: , breed:)
        sql = <<-SQL
                SELECT * FROM dogs WHERE name = ? AND breed = ?;
            SQL
        info = DB[:conn].execute(sql, name, breed)[0]
        if !info.nil? && info.length > 0
            self.new_from_db(info)
        else    
            self.create(name: name, breed: breed)
        end
    end


    attr_accessor :id, :name, :breed

    def initialize(id: nil, name: , breed:) 
        @id = id
        @name = name
        @breed = breed    
    end


    def save
        if self.id.nil?
            self.insert
        else
            self.update
        end
        self
    end

    def update
        sql = <<-SQL
                UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
            SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def insert
        sql = <<-SQL 
                INSERT INTO dogs(name, breed) VALUES (?, ?);
            SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
end