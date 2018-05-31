class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: nil, breed: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create(name:, breed:)
    new_dog = new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog = new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def save
    if self.id
      update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT(1)"
    DB[:conn].execute(sql, name).map { |row| new_from_db(row) }.first
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map { |row| new_from_db(row) }.first
  end

  def self.find_or_create_by(name:, breed:)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
    if !dog_data.empty?
      dog = new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = create(name: name, breed: breed)
    end
    dog
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

end
