class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
    self
  end

  def self.create(attributes)
    self.new(name: attributes[:name], breed: attributes[:breed]).save
  end

  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    self.new(id: dog[0], name: dog[1], breed: dog[2])
  end

  def self.find_or_create_by(attributes)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
    if !dog.empty?
      dog_data = dog[0]
      self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      self.create(name: attributes[:name], breed: attributes[:breed])
    end
  end

  def self.new_from_db(row)
    self.create({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    self.new(id: dog[0], name: dog[1], breed: dog[2])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
