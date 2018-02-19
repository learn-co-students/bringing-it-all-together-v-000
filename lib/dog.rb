require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    # has a name and a breed
    # has an id that defaults to nil on initialization
    # accepts key value pairs as arguments to initialize
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
      # binding.pry
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    # returns an instance of the dog class
    # saves an instance of the dog class to the database and then sets the given dogs `id` attribute
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    # takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to
    # save that dog to the database
    # returns a new dog object
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    new_dog = Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def self.find_or_create_by(hash)
    # creates an instance of a dog if it does not already exist
    # when two dogs have the same name and different breed, it returns the correct dog
    breed = hash[:breed]
    name = hash[:name]
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
        dog = self.create(hash)
      end
    dog
  end

  def self.new_from_db(row)
    # creates an instance with corresponding attribute values
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
