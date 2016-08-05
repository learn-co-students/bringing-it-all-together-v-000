class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end
  

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end     

  def save
    if self.id
      self.update
    else

    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES(?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT id, name, breed FROM dogs WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    dog = Dog.new(id:row[0], name:row[1], breed: row[0])
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT id, name, breed FROM dogs WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
      dog = Dog.new(id: dog[0][0], name:dog[0][1], breed: dog[0][2])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL

    dog_finder = DB[:conn].execute(sql, name)[0]
    dog = Dog.new(id: dog_finder[0], name: dog_finder[1], breed: dog_finder[2])
  end

end

