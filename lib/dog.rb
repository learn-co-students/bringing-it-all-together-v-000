class Dog

  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE dogs (
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

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id (x)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL
    self.new_from_db(DB[:conn].execute(sql, x)[0])
    #result = DB[:conn].execute(sql, x)[0]
    #Dog.new(name: result[1], breed: result[2], id: result[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
      SQL
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(name: dog_info[1], breed: dog_info[2], id: dog_info[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    Dog.new(name: name, breed: breed, id: id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
