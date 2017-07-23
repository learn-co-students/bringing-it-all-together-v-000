require "pry"

class Dog

  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
    # binding.pry
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
    sql = "DROP TABLE IF EXISTS dogs"

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
      self
    end

  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.create(attributes)
    dog = self.new(attributes)

    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    dog_info = DB[:conn].execute(sql, id)[0]

    self.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
  end

  def self.find_or_create_by(name:, breed:)
    if self.find_by_name(name).breed == breed
      dog = self.find_by_name(name)
    else
      self.create({name: name, breed: breed})
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    dog_info = DB[:conn].execute(sql, name)[0]

    self.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
  end

  def self.new_from_db(row)
    self.new(id:row[0], name:row[1], breed:row[2])
  end

end
