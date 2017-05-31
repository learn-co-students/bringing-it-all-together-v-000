class Dog

  attr_accessor :name, :breed, :id

  def initialize(attributes_hash)
    @id = nil
    attributes_hash.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
  sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
        SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
   DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.create(attributes_hash)
    dog = Dog.new(attributes_hash)
    dog.save
    dog
  end

  def save
  # given a dog instance insert if it doesn't exist
  # otherwise update
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
    end
    self
  end

  def self.new_from_db(row)
# take attributes from row and make obj
    attributes_hash = {id: row[0], name: row[1], breed: row[2]}
    new_dog = Dog.new(attributes_hash)
  end

  def self.find_by_name(dog_name)
  # Get row from database then call new_from_db
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
    row = DB[:conn].execute(sql, dog_name).flatten
    dog_from_db = Dog.new_from_db(row)
  end

  def self.find_by_id(dog_id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
    row = DB[:conn].execute(sql, dog_id).flatten
    dog_from_db = Dog.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, name, breed)
    if !row.empty?
      dog = Dog.new_from_db(row[0])
    else
      attributes_hash = {id: row[0], name: row[1], breed: row[2]}
      dog = Dog.create(attributes_hash)
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
