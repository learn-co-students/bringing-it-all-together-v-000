class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs(name, breed) VALUES (?, ?)", @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    self.new(attributes).save
  end

  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.id = ?", id).first
    self.new(id:dog[0], name:dog[1], breed:dog[2]) if dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.name = ? AND dogs.breed = ?", name, breed).first
    if dog
      self.new(id:dog[0], name:dog[1], breed:dog[2])
    else
      self.create(name:name, breed:breed)
    end
  end

  def self.new_from_db(row)
    self.create(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.name = ? LIMIT 1", name).first
    self.new(id:dog[0], name:dog[1], breed:dog[2]) if dog
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", @name, @breed, @id)
  end
end
