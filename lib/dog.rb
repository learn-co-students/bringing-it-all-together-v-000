require 'pry'

class Dog

  attr_accessor :id, :name, :breed

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

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed:row[2])
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(dog)
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
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    self.new_from_db(dog)
  end

  def self.find_or_create_by(name:, breed:)
    found_dog = self.find_by_name(name)
    if found_dog.name != name || found_dog.breed != breed
      self.create(name: name, breed: breed)
    else
      found_dog
    end
  end

end
