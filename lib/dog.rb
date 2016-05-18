require 'pry'
class Dog
  attr_accessor :id, :name, :breed

  def initialize(input)
    @name = input[:name]
    @breed = input[:breed]
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    newdog = Dog.new(hash)
    newdog.save
  end

  def self.find_by_id(id)
    dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
    newdog = Dog.new(name: dog_array[1], breed: dog_array[2])
    newdog.id = dog_array[0]
    newdog
  end

  def self.find_or_create_by(hash)
    dog = self.find_by_name_and_breed(hash[:name], hash[:breed])
    if dog.nil?
      return self.create(hash)
      else
      return dog
    end
  end

  def self.find_by_name(input)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", input)
    return nil if dog.empty?
    new_from_db(dog.first)
  end

  def self.find_by_name_and_breed(name, breed)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", name, breed)
    return nil if dog.empty?
    new_from_db(dog.first)
  end

  def self.new_from_db(array)
    newdog = self.new(name: array[1], breed: array[2])
    newdog.id = array[0]
    newdog
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end