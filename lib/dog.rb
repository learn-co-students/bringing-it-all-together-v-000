require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id = nil, dog_hash)
    @id = id
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
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

  def save
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

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(dog_hash)
      new_dog = Dog.new(dog_hash)
      new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    dog_hash = {:name => result[1], :breed => result[2]}
    Dog.new(result[0], dog_hash)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog_hash = {:name => dog[1], :breed => dog[2]}
      dog = Dog.new(dog_data[0], dog_hash)
    else
      dog_hash = {:name => name, :breed => breed}
      dog = self.create(dog_hash)
    end
    dog
  end

  def self.new_from_db(row)
    dog_hash = {:name => row[1], :breed => row[2]}
    new_dog = self.new(row[0], dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    dog_hash = {:name => row[1], :breed => row[2]}
    Dog.new(row[0], dog_hash)
  end

end
