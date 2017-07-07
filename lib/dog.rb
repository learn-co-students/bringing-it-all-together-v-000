class Dog
  attr_accessor :name, :breed, :id


   def initialize(id: nil, name:, breed:)
     @name = name
     @breed = breed
     @id = id
   end

    def self.create_table
      sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql =  <<-SQL
        DROP TABLE dogs
      SQL
      DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
         DB[:conn].execute(sql, self.name, self.breed)
         @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
         self
    end

    def self.create(row)
      dog = self.new(row)
      dog.save
      dog
    end

    def self.new_from_db(row)

      hash = {
        id: row[0],
        name: row[1],
        breed: row[2]
      }
      new_dog = Dog.new(hash)
    end

    def self.find_by_id(num)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
      SQL
      result = DB[:conn].execute(sql, num)
      dog = self.new_from_db(result[0])
      dog
    end

    def self.find_by_name(name)

      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
      SQL
      result = DB[:conn].execute(sql, name)
      dog = self.new_from_db(result[0])
      dog
    end

    def self.find_or_create_by(name:, breed:)

      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      dog_data = dog[0]

       if !dog.empty?

        hash = {
          id: dog_data[0],
          name: dog_data[1],
          breed: dog_data[2]
        }
        new_dog = self.new(hash)
       else
         new_dog = self.create(name: name, breed: breed)
       end
       new_dog
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
