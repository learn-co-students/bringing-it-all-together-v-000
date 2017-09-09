class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
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
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ? LIMIT 1
      SQL
    attributes = DB[:conn].execute(sql, id)[0]
    self.new_from_db(attributes)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ? LIMIT 1
      SQL
    attributes = DB[:conn].execute(sql, name, breed)
    if attributes.empty?
      self.create(name: name, breed: breed)
    else
      self.new_from_db(attributes[0])
    end
  end

  def self.new_from_db(attributes)
    id, name, breed = attributes
    dog = Dog.new(name: name, breed: breed)
    dog.id = id
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? LIMIT 1
      SQL
    attributes = DB[:conn].execute(sql, name)
    self.new_from_db(attributes[0])
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