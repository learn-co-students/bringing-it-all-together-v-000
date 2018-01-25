class Dog
  attr_accessor :name, :breed, :id

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
  end

  def self.drop_table
    sql = "DROP TABLE dogs;"

    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"

    DB[:conn].execute(sql, name, breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def self.create(dog)
    dog = self.new(dog)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    dog = DB[:conn].execute(sql, id)[0]
    self.new(id: dog[0], name: dog[1], breed: dog[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    dog = DB[:conn].execute(sql, name)[0]
    self.new(id: dog[0], name: dog[1], breed: dog[2])
  end
end
