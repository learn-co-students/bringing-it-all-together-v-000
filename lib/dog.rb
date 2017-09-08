require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
      self
    end
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map do |x|
      self.new_from_db(x)
    end.first
  end

  def self.find_by_breed(breed)
    sql = "SELECT * FROM dogs WHERE breed = ?"
    DB[:conn].execute(sql, breed).map do |x|
      self.new_from_db(x)
    end.first
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map do |x|
      Dog.new_from_db(x)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name:, breed:)
    if self.find_by_breed(breed) && self.find_by_name(name)
      self.find_by_breed(breed)
      self.find_by_name(name)
    else
      self.create(name: name, breed: breed)
    end
  end

end
