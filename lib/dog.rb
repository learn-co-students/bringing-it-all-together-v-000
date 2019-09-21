require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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
      sql_get_id = <<-SQL
        SELECT id FROM dogs ORDER BY id DESC LIMIT 1
      SQL
      @id = DB[:conn].execute(sql_get_id)[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
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

  def self.create(dog_hash)
    new_obj = Dog.new(dog_hash)
    new_obj.save
    new_obj
  end

  def self.new_from_db(row)
    new_obj = self.new(name: row[1], breed: row[2], id: row[0])
    new_obj
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE id = ? LIMIT 1
    SQL

    dog_array = DB[:conn].execute(sql, id)
    self.new_from_db(dog_array[0])
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog_specs = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])
    if dog_specs[0]
      self.find_by_id(dog_specs[0][0])
    else self.create(dog_hash)
    end
  end

end
