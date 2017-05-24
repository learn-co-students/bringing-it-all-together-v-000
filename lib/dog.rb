class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs(name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL
    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_info = dog.flatten
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL
    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.id)
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
    DB[:conn].execute("DROP TABLE dogs")
  end
end
