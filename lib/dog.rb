class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name: name, breed: breed)
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

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
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
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
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
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end
    
    def self.create(attributes)
        dog = self.new.tap do |dog_instance|
            attributes.each do |attribute_name, attribute_value|
                dog_instance.send("#{attribute_name}=", attribute_value)
            end
        end
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
    end

    def ==(other_dog)
        self.name == other_dog.name
        self.breed == other_dog.breed
    end

    def self.find_or_create_by(attributes)
        dog_from_db = self.find_by_name(attributes[:name])
        
        if dog_from_db.breed == attributes[:breed]
            dog_from_db
        else
            self.create(attributes)
        end
    end

end
