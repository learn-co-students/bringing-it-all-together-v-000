require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(dog_hash, id = nil)
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    a = self.new(hash)
    a.save
  end

  def self.find_by_id(id)
    dog_hash = {}
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog_hash[:name] = DB[:conn].execute(sql, id)[0][1]
    dog_hash[:breed] = DB[:conn].execute(sql, id)[0][2]
    dog_hash[:id] = id

    a = self.new(dog_hash)
    a.id = id
    a
  end

  def self.find_or_create_by(hash)
    dog_hash = {}
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    find = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !find.empty?
      found_dog = find[0]
      dog_hash[:name] = found_dog[1]
      dog_hash[:breed] = found_dog[2]
      dog_hash[:id] = found_dog[0]
      new_dog = self.new(dog_hash, dog_hash[:id])

    else

      dog_hash[:name] = hash[:name]
      dog_hash[:breed] = hash[:breed]
      new_dog = self.create(dog_hash)
    end
    new_dog
  end

  def self.new_from_db(db)
    dog_hash = {}
    dog_hash[:name] = db[1]
    dog_hash[:breed] = db[2]
    db_dog = self.new(dog_hash)
    db_dog.id = db[0]
    db_dog
  end

  def self.find_by_name(db)
    dog_hash = {}
    sql = "SELECT * FROM dogs WHERE name = ?"
    found_dog = DB[:conn].execute(sql, db)
    dog_hash[:name] = found_dog[0][1]
    dog_hash[:breed] = found_dog[0][2]
    new_dog = self.new(dog_hash)
    new_dog.id = found_dog[0][0]
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

end
