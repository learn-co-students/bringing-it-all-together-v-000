class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
     CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
       self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    object = DB[:conn].execute(sql, id).first
    Dog.new(id: object[0], name: object[1], breed: object[2])
  end

  def self.find_or_create_by(name:, breed:)
    two_dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !two_dogs.empty?
        new_dog = two_dogs[0]
        two_dogs = self.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
      else
        two_dogs = self.create(name: name, breed: breed)
      end
        two_dogs
  end

  def self.new_from_db(breed)
    id = breed[0]
    name = breed[1]
    breed = breed[2]
    new_dog = self.new(id: id, name: name, breed: breed)
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    name = DB[:conn].execute(sql, name)[0]
    self.new(id: name[0], name: name[1], breed: name[2])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
