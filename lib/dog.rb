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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

    self
  end

  def self.create(name:, breed:)
    Dog.new(name: name, breed: breed).save
  end

  def self.find_by_id(id_num)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id_num)[0]
    Dog.new(name: row[1], breed: row[2], id: id_num)
  end

  def self.find_or_create_by(name:, breed:)
    db_dog = DB[:conn].execute("SELECT * from DOGS WHERE name = ? AND breed = ?", name, breed)

    if db_dog.empty?
      new_dog = self.create(name: name, breed: breed)
    else
      new_dog = Dog.new(name: name, breed: breed, id: db_dog[0][0])
    end

    new_dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0]
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
