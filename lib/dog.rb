class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
  # has an id that defaults to `nil` on initialization
  # accepts key value pairs as arguments to initialize
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
  # creates the dogs table in the database
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
  # drops the dogs table from the database
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def update
  # updates the record associated with a given instance
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
  # returns an instance of the dog class
  # saves an instance of the dog class to the database and then sets the given dogs `id` attribute
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
  # takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database
  # returns a new dog object
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(dog_row)
  # creates an instance with corresponding attribute values
    id = dog_row[0]
    name = dog_row[1]
    breed = dog_row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_id(id)
  # returns a new dog object by id
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL

    dog_row = DB[:conn].execute(sql, id)
    self.new_from_db(dog_row[0])
    #    DB[:conn].execute(sql,id).map do |row|
    #      self.new_from_db(row)
    #    end.first
  end

  def self.find_or_create_by(name:, breed:)
  # creates an instance of a dog if it does not already exist
  # when two dogs have the same name and different breed, it returns the correct dog
  # when creating a new dog with the same name as persisted dogs, it returns the correct dog
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    if !dog_row.empty?
      dog = self.new_from_db(dog_row[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
  # returns an instance of dog that matches the name from the DB
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    dog_row = DB[:conn].execute(sql, name)
    self.new_from_db(dog_row[0])
  end


end
