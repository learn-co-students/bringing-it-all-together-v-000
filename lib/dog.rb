class Dog
    attr_accessor :id, :name, :breed


#The #initialize method accepts a hash or keyword argument value with key-value pairs as an argument. key-value pairs need to contain id, name, and breed.
    def initialize (id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed

    end
#define a class method on Dog that will execute the correct SQL to create a dogs table.
    def self.create_table
        sql = <<-SQL
              CREATE TABLE IF NOT EXISTS dogs
              (id INTEGER PRIMARY KEY,
              name TEXT,
              age INTEGER)
              SQL
        DB[:conn].execute(sql)
    end
#drop table
    def self.drop_table
        sql = <<-SQL
              DROP TABLE dogs
              SQL
        DB[:conn].execute(sql)
    end
#This is an interesting method. Ultimately, the database is going to return an array representing a dog's data. We need a way to cast that data into the appropriate attributes of a dog. This method encapsulates that functionality. You can even think of it as new_from_array. Methods like this, that return instances of the class, are known as constructors, just like ::new, except that they extend the functionality of ::new without overwriting initialize.
#arguments use hashes
    def self.new_from_db(row_array)
      new_dog = self.new(id: row_array[0], name: row_array[1], breed: row_array[2])
      new_dog
    end
#This spec will first insert a dog into the database and then attempt to find it by calling the find_by_name method. The expectations are that an instance of the dog class that has all the properties of a dog is returned, not primitive data.
#Internally, what will the find_by_name method do to find a dog; which SQL statement must it run? Additionally, what method might find_by_name use internally to quickly take a row and create an instance to represent that data?
    def self.find_by_name(name)
        sql = <<-SQL
                SELECT *
                FROM dogs
                WHERE name = ?
              SQL
        result = DB[:conn].execute(sql, name)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end
#This spec will create and insert a dog, and after, it will change the name of the dog instance and call update. The expectations are that after this operation, there is no dog left in the database with the old name. If we query the database for a dog with the new name, we should find that dog and the ID of that dog should be the same as the original, signifying this is the same dog, they just changed their name.
    def update
      sql = <<-SQL
              UPDATE dogs
              SET name = ?, breed = ?
              WHERE id = ?
            SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
#This spec ensures that given an instance of a dog, simply calling save will trigger the correct operation. To implement this, you will have to figure out a way for an instance to determine whether it has been persisted into the DB.
#In the first test we create an instance, specify, since it has never been saved before, that the instance will receive a method call to insert.
#In the next test, we create an instance, save it, change its name, and then specify that a call to the save method should trigger an update.
    def save
      #does it EXIST in db already
      if self.id
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
    def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
      dog
    end
    def self.find_by_id(id)
      sql = <<-SQL
                SELECT *
                FROM dogs
                WHERE id = ?
            SQL

      result = DB[:conn].execute(sql, id)[0]
      Dog.new(id: result[0], name: result[1], breed: result[2])
    end
    def self.find_or_create_by(name:, breed:)
          dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
          if !dog.empty?
                dog_data = dog[0]
                dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
          else
              dog = self.create(name:name, breed:breed)
          end
          dog
    end


end
