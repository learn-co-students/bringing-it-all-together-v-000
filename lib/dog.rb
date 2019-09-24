class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    self.name = attributes[:name]
    self.breed = attributes[:breed]
    self.id = nil
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)"
    )
  end

  def self.create(attributes)
    dog = new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    new_from_db(row)
  end

  def self.find_or_create_by(attributes)
    query = DB[:conn].execute(
      "SELECT id FROM dogs WHERE name = ? AND breed = ?",
      attributes[:name], attributes[:breed]
    )
    unless query.empty?
      find_by_id(query[0][0])
    else
      create(attributes)
    end
  end

  def self.new_from_db(row)
    dog = new({name: row[1], breed: row[2]})
    dog.id = row[0]
    dog
  end

  def self.find_by_name(name)
    id = DB[:conn].execute(
      "SELECT id FROM dogs WHERE name = ? LIMIT 1", name
    )[0][0]
    find_by_id(id)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      update
    else
      DB[:conn].execute(
        "INSERT INTO dogs (name, breed) VALUES (?, ?)",
        self.name, self.breed
      )
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    DB[:conn].execute(
      "UPDATE dogs SET name = ?, breed = ? WHERE id = ?",
      self.name, self.breed, self.id
    )
  end

end
