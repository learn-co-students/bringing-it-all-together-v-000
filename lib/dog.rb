class Dog
    attr_accessor :id , :name, :breed

    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
        self.id ||= nil
    end

    #create_table that creates the dogs table in the DB
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    #drop_table that drops the dogs table from the DB
    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
            SQL
        DB[:conn].execute(sql)
    end

    #new_from_db
    def self.new_from_db(row) #methods like this, that return instances of the class, are known as constructors, just like .new, except that they extend the functionality of .new without overwritting initalize.
        attributes_hash = {
            :id => row[0],
            :name => row[1],
            :breed => row[2]
          }
          self.new(attributes_hash) #creates an instance with corresponding attribute values
    end

    #find_by_name method that returns an instance of dog that matched the name from the DB
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name= ?
            SQL
            DB[:conn].execute(sql, name).map do |row|
                self.new_from_db(row)
            end.first
    end

    #update method that updates the record associated with a given instance
    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    #save 
    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
        SQL
        #saves an instance of the dog class to the DB and then sets the given dogs `id` attribute
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] 
        #returns an instance of the dog class
        self
    end

    # create 
    def self.create(hash_of_attributes) #takes in a hash of attributes
        dog = self.new(hash_of_attributes) #uses metaprogramming to create a new dog object
        dog.save #uses save method to save dog to DB
        dog #returns a new dog object
    end

    #find_by_id
    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row) #returns a new dog object by id
        end.first
    end

    #find_or_create_by
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        dog = DB[:conn].execute(sql, name, breed).first
        if dog
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create({:name => name, :breed => breed}) 
        end
        new_dog  
    end

end
