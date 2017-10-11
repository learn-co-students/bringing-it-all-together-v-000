require 'pry'

class Dog
  attr_accessor :name, :breed, :id
  # attr_reader :id

  def initialize(hash)
    hash.map { |key, value| self.send("#{key}=", value) }
    # @id, @name, @breed = id, name, breed
  end

  ## Class Methods ##

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )"

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]

    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"

    DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }.first
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"

    DB[:conn].execute(sql, id).map { |row|  self.new_from_db(row) }.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, name, breed)

    row = dog[0]

    if !dog.empty?
      self.new_from_db(row)
    else
      self.create(name: name, breed: breed)
    end
  end

  ## Instance Methods ##

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    self.update if self.id

    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end



end
