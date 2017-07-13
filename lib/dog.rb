class Dog

  attr_accessor :id, :name, :breed

  #accepts key:value as arguments
  def initialize(id: nil, name:, breed:)
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
    sql ="DROP TABLE dogs"
    DB[:conn].execute(sql)
  end


#returns an instance of the dog class
#saves an instance of the dog class to the database and then sets the given dogs `id` attribute
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end




  #takes in a hash of attributes and uses metaprogramming to create a new dog object.
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    #Then it uses the #save method to save that dog to the database
    dog.save
    #returns a new dog object
    dog
  end

#creates an instance with corresponding attribute values
  def self.new_from_db(row)
    #get the info from the row, which is an array
    id = row[0]
    name = row[1]
    breed = row[2]
    #assign the values to a new instance of dog
    self.new(id: id, name:name, breed: breed)
  end

# returns a new dog object by id
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

 #returns an instance of dog that matches the name from the DB
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

  #creates an instance of a dog if it does not already exist
  #when two dogs have the same name and different breed, it returns the correct dog
  #when creating a new dog with the same name as persisted dogs, it returns the correct dog

  def self.find_or_create_by(name:, breed:)
    #first search in the dog on the database
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    #if the dog exists it will point to an array for the dog, we use dog[0] to get the first array.
      if !dog.empty?
        dog_info = dog[0]
      #we will use the returned values to make a new "Dog" object that Ruby can play around with,
			# but we will not save it to the database.
      #We grab the dog_info from the dog array of arrays,
			#Then we use this array to create a new song instance
      #this are hash pairs so we still need to treat them as such by using 'id:, name:, breed:'
        dog = Dog.new(id: dog_info[0],name: dog_info[1],breed: dog_info[2])
      else
        #else if no record exist that matches we will create and save a new dog instance with the .create method
        dog = self.create(name: name, breed: breed)
      end
      #return the dog object that was found or created. Therefore we never duplicate records in the database.
      dog
    end

    def update
      #id's are unique so we can update the name and the breed by id.
      sql =<<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
