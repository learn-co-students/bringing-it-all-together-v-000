class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
  end

  def self.create_table
    dogs = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(dogs)
  end

  def self.drop_table
    dogs = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(dogs)
  end

  def save #to save it to the database
    dogs = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(dogs, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name, breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    dogs = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

    row = DB[:conn].execute(dogs, id)[0]
    dog = self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)

    search = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?, breed = ?", name, breed)

    if !search.empty?
      row = search[0]
      dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    dog = Dog.new(id: id, name: name, breed: breed)
    dog
  end
end
