class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil,name:, breed:)
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
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog = DB[:conn].execute(sql, id)[0]
    new_dog = self.new(id: dog[0], name: dog[1], breed: dog[2])
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog = DB[:conn].execute(sql, name, breed)[0]
    if dog.nil?
      self.create(name: name, breed: breed)
    else
      self.find_by_id(dog[0])
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    dog = DB[:conn].execute(sql, name)[0]
    new_dog = self.new_from_db(dog)
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    updated_dog = DB[:conn].execute(sql, self.name, self.breed, self.id)
    updated_dog
  end

end
