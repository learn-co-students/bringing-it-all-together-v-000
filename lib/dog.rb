require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

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
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?,?)', self.name, self.breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name: name, breed: breed)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    self.new(name:row[1], breed:row[2], id:row[0])
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    self.new_from_db(row)
  end

  def self.find_or_create_by(name: name, breed: breed)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    if DB[:conn].execute(sql, name, breed) != []
      id = DB[:conn].execute(sql, name, breed).flatten[0]
      self.find_by_id(id)
    else
      new_dog = self.create(name: name, breed:breed)
      new_dog
    end
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    self.new_from_db(row)
  end
end
