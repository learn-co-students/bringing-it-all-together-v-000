class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    self.name = name
    self.breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes_hash)
    self.new(name: nil, breed: nil).tap do |dog|
      attributes_hash.each do |key, value|
        dog.send("#{key}=", value)
      end
      dog.save
    end
  end

  def self.find_by_id(id)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0][0])
  end

  def self.new_from_db(row)
    self.new(name: nil, breed: nil).tap do |dog|
      dog.name = row[1]
      dog.breed = row[2]
      dog.id = row[0]
    end
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog =self.new_from_db(dog[0])
    else
      dog = self.new(name: name, breed: breed)
      dog.save
    end
    dog
  end

  def self.find_by_name(name)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
