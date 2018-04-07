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
    sql = <<-SQL
      DROP TABLE dogs
      SQL
    DB[:conn].execute(sql)
  end

  def self.create(hash_of_attributes)
    name = hash_of_attributes[:name]
    breed = hash_of_attributes[:breed]
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE ID = ?
      SQL
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE NAME = ? AND BREED = ?
      SQL
    result = DB[:conn].execute(sql, name, breed)[0]
    if result == nil
      dog = Dog.new(name: name, breed: breed)
      dog.save
      dog
    else
      Dog.new(id: result[0], name: result[1], breed: result[2])
    end
  end

  def self.new_from_db(row)
     id = row[0]
     name = row[1]
     breed = row[2]
     Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE NAME = ?
      SQL
    result = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(result)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.id)
  end

  def save
    sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

end
