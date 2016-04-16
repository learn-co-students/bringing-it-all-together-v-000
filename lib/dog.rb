class Dog

  # has a name and a breed
  attr_accessor :id, :name, :breed

  # has an id that defaults to `nil` on initialization
  # accepts key value pairs as arguments to initialize
  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  # creates the dogs table in the database
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

  # drops the dogs table from the database
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  # saves an instance of the dog class to the database
  # and then sets the given dogs `id` attribute
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
  end

  # takes in a hash of attributes and uses metaprogramming
  # to create a new dog object. Then it uses the #save
  # method to save that dog to the database
  def self.create(name: , breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  # creates an instance with corresponding attribute values
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end


  # returns a new dog object by id
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end

  # returns an instance of dog that matches the name from the DB
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end

  # creates an instance of a dog if it does not already exist
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: name)
    end
    dog
  end

end
