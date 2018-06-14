class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name: , breed: , id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs(name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attr_hash)
    dog = self.new(attr_hash)
    dog.save
  end

  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2], id: row[0])
    new_dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map { |row|
      self.new_from_db(row)
    }.first
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    DB[:conn].execute(sql, id).map { |row|
      self.new_from_db(row)
    }.first
  end

  def self.find_or_create_by(name: , breed:)
    sql_select = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"

    dog_data = (DB[:conn].execute(sql_select, name, breed))
    if dog_data == []
      dog = self.create({name: name, breed: breed})
    else
      dog = self.new_from_db(dog_data[0])
    end
    dog
  end

end
