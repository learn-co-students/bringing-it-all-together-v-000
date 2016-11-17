class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<~SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = "INSERT INTO dogs(name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("Select last_insert_rowid() FROM dogs").flatten.first
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    dog_params = DB[:conn].execute(sql, id).flatten
    id, name, breed = dog_params[0], dog_params[1], dog_params[2]
    dog = self.new(id: id, name: name, breed: breed)
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog_params = DB[:conn].execute(sql, name, breed).flatten
    if !dog_params.empty?
      dog = self.new(id: dog_params[0], name: dog_params[1], breed: dog_params[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    id, name, breed = row[0], row[1], row[2]
    dog = self.new(id: id, name: name, breed: breed)
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name).flatten
    dog = self.new_from_db(row)
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id) if self.id
    self
  end
end
