require 'pry'
class Dog
  @@all = []
  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
    @@all << self
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    new_dog
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

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    dog = DB[:conn].execute(sql, name)[0][0]
    @@all [dog - 1]
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

  def self.find_or_create_by(attribute_hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    #binding.pry
    dog = DB[:conn].execute(sql, attribute_hash[:name], attribute_hash[:breed])[0]
    if dog
      @@all[dog[0] - 1]
    else
      self.create(attribute_hash)
    end
  end

  def self.create(attribute_hash)
    new_dog = Dog.new(attribute_hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    dog = DB[:conn].execute(sql, id)[0][0] - 1
    @@all[dog]
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

  def self.clear_all
    @@all.clear
  end
end
