class Dog

  attr_accessor :id, :name, :breed

  def initialize(hash)
      @id = hash[:id]
      @name = hash[:name]
      @breed = hash[:breed]
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE dogs ( id INTEGER PRIMARY KEY, name TEXT, breed TEXT );")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

  def self.new_from_db(row)
    new_dog = Dog.new({id: row[0], name: row[1], breed: row[2]})
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
    if dog.empty?
      dog = self.create({name: dog[1], breed: dog[2]})
    else
      dog = self.new({id: dog[0], name: dog[1], breed: dog[2]})
    end
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"

    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end
end
