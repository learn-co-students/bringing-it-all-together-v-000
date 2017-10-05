require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE students SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


  def save
      if self.id
        self.update
      else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?) "

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      new_dog = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0]
      dog = Dog.new(id:new_dog[0], name: new_dog[1], breed: new_dog[2])
      dog
    end
  end

  def self.create(name:, breed:)
    # binding.pry
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    new_dog = DB[:conn].execute(sql, id)[0]
    Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog_found = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog_found.empty?
      new_dog = dog_found[0]
      dog = Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
    # binding.pry
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    dog = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ?"
    DB[:conn].execute(sql, self.name, self.breed)
  end

end
