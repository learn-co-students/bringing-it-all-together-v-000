class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1;"
    dog_data = DB[:conn].execute(sql, id).first
    Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog_data = DB[:conn].execute(sql, name, breed)
    if !dog_data.empty?
      return Dog.new(id: dog_data[0][0], name: dog_data[0][1], breed: dog_data[0][2])
    else
      return Dog.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1;"
    dog_data = DB[:conn].execute(sql, name).first
    Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end
end