class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIME KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
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

  def self.create(hash)
    new_dog = Dog.new(name:hash[:name], breed:hash[:breed])
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

    value = DB[:conn].execute(sql, id)[0]
    hash = {id: value[0], name: value[1], breed: value[2]}

    self.new(hash)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_hash = {id: dog[0][0], name: dog[0][1], breed: dog[0][2]}
      dog = Dog.new(dog_hash)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(array)
    dog_hash = {id: array[0], name: array[1], breed: array[2]}
    self.new(dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    val = DB[:conn].execute(sql, name).first
    self.find_or_create_by(name:val[1], breed:val[2])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id= ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
