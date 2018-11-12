require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
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
      DROP TABLE IF EXISTS dogs
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

  def self.create(attributes)
    dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql, id)

    Dog.new(name: dog[0][1], breed: dog[0][2], id: dog[0][0])
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog_info = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

    if !dog_info.empty?
      dog = Dog.new(name: dog_info[0][1], breed: dog_info[0][2], id: dog_info[0][0])
    else
      dog = Dog.create(attributes)
    end
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    dog = DB[:conn].execute(sql, name)
    
    Dog.new(name: dog[0][1], breed: dog[0][2], id: dog[0][0])
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