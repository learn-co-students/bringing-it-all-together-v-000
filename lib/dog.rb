require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(dog)
    @id = nil
    @name = dog[:name]
    @breed = dog[:breed]
  end
  
  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def self.new_from_db(dog)
    Dog.new(dog[0], dog[1], dog[2])
  end
  
  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    Dog.new(dog[0], dog[1], dog[2])
  end
  
  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end
  
  def save
    if self.id
      self.update
      self
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs ")[0][0]
      self
    end
  end
  
  def self.create(dog_hash)
    dog = Dog.new(dog_hash)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    new_dog = Dog.new(name: dog[1], breed: dog[2])
    new_dog.id = dog[0]
    new_dog
  end
  
  def self.find_or_create_by(dog_hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", dog_hash[:name], dog_hash[:breed]).flatten
    if !dog.empty?
      Dog.find_by_id(dog[0])
    else
      Dog.create(dog_hash)
    end
  end
  
  def self.new_from_db(dog_array)
    dog = Dog.new(name: dog_array[1], breed: dog_array[2])
    dog.id = dog_array[0]
    dog
  end
  
  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    new_dog = Dog.new(name: dog[1], breed: dog[2])
    new_dog.id = dog[0]
    new_dog
  end
end