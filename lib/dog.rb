require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    self.name = name
    self.breed = breed
    self.id = id
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
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)

  end

  def self.new_from_db(row)
    Dog.new(name:row[1], breed: row[2], id:row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    dog_found = DB[:conn].execute(sql, name).first
    dog_instance = Dog.new(name: dog_found[1], breed: dog_found[2], id:dog_found[0])

  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:,id: nil)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    results = DB[:conn].execute(sql, name, breed)
    if !results.empty?
      dog = Dog.new(name: results[0][1], breed: results[0][2], id: results[0][0])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.id)

  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end


end
