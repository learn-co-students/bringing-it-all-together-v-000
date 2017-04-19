require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(data_hash)
    @id = data_hash[:id]
    @name = data_hash[:name]
    @breed = data_hash[:breed]
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
      DROP TABLE dogs
      SQL

    DB[:conn].execute(sql)
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

      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
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

  def self.new_from_db(data)
    id = data[0]
    name = data[1]
    breed = data[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
      SQL

    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def self.create(dog_hash)
    dog = self.new(dog_hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
      SQL

    DB[:conn].execute(sql, id).map {|data| self.new_from_db(data)}.first
  end

  def self.find_or_create_by(name:, breed:)
    data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !data.empty?
      dog_data = data[0]
      data = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      data = self.create(name: name, breed: breed)
    end
    data
  end
end
