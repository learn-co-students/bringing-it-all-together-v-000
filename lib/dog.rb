require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = attributes[:id] ? attributes[:id] : nil
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT MAX(id) FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.array_to_hash(array)
    hash = {}
    hash[:id] = array[0]
    hash[:name] = array[1]
    hash[:breed] = array[2]
    hash
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map { |row| Dog.new(self.array_to_hash(row)) }[0]
  end

  def self.find_or_create_by(attributes)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
    if !dog.empty?

      sent_attribute = {id: dog[0][0], name: dog[0][1], breed: dog[0][2]}
      dog = Dog.new(sent_attribute)
    else
      dog = self.create(attributes)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(array_to_hash(row))
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map { |row| Dog.new(array_to_hash(row)) }[0]
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end