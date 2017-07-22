class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil) #initialize with key words
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS
    dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row) #creates dog instance from array of data
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = Dog.new(name: name, breed: breed, id: id) #matches the key in intialize with a value from the row array
    #possibly add: new_dog to explicitly return dog instance at the end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row|
      Dog.new_from_db(row)
    end.first #without .first, the return value of the method is an array, e.g. [#<Dog:0x0000000187fce8 @name="Teddy", @breed=
      #"cockapoo", @id=1>]; .first picks out the dog instance
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id #i.e. if the dog instance already persists in the DB
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] #[0][0] because id is the first item in the first subarray that is returned
    end
    self
  end

  def self.create(argument_hash) #argument_hash bunches together name:, breed:
    dog = Dog.new(argument_hash)
    dog.save
    #dog --finally dog not necessary as it is already return value of .save method
  end

  def self.find_by_id(id) #same structure as find_by_name
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id == ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
      if !dog.empty? #i.e. if the DB does contain a dog with that name and breed
        dog_data = dog[0] #DB[:conn].execute returns array of arrays, so dog[0] is the actual array of data
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      #or: dog = Dog.new(dog_data)
      else
        dog = self.create(name: name, breed: breed)
      end
      dog
    end
end
