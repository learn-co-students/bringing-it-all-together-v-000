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
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<~SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
     self.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1;"
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1;", name, breed)
    if !dog.empty?
      self.new_from_db(dog[0])
    else
      self.create(name: name, breed: breed)
    end
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1;", name)[0])
  end
end
