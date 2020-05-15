class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name: nil, breed: nil)
        @id, @name, @breed = id, name, breed
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (id integer primary key, name text, breed text)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def self.create(attributes)
        dog = self.new.tap do |dog|
            attributes.each {|key, value| dog.send("#{key}=", "#{value}")}
            dog.save
        end
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs where id = ?"
        DB[:conn].execute(sql, id).map { |row|  self.new_from_db(row)}.first
    end


    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs where name = ?"
        DB[:conn].execute(sql, name).map { |row|  self.new_from_db(row)}.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? where id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) values (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.find_or_create_by(attributes)
        # dog_from_db = Dog.find_or_create_by({name: 'teddy', breed: 'cockapoo'})
        # find ->update
        # not find => create

        sql = "SELECT * FROM dogs where name = ? and breed = ?"
        result = DB[:conn].execute(sql, attributes.values[0], attributes.values[1])

        if !result.empty? #exists in dogs table
            dog = self.new(id: result[0][0], name: result[0][1], breed: result[0][2])
        else
            dog = self.create(attributes)
        end
    end
end
