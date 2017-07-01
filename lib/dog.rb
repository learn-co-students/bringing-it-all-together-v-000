class Dog

  attr_accessor :name, :breed
  attr_reader :id

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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    self.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog_data = DB[:conn].execute(sql, name, breed)
    unless dog_data.empty?
      self.new_from_db(dog_data.first)
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def initialize(id: nil, name:, breed:)
    @id, self.name, self.breed = id, name, breed
  end

  def save
    unless self.id
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first.first
    else
      self.update
    end

    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end