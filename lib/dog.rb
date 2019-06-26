class Dog
  attr_accessor :name, :breed
  attr_reader :id

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
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    # return a dog array from the database
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    # create a new dog object using metaprogramming
    dog = self.new(name: name, breed: breed)
    # save that dog to the database
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT dogs.* FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def self.find_or_create_by(name:, breed:)
    # query the database
    dog = DB[:conn].execute("SELECT dogs.* FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      # reinstantiate an existing Dog object
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT dogs.* FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
