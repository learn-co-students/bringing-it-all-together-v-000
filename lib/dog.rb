require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash.fetch(:name)
    @breed = hash.fetch(:breed)
    @id = hash.fetch(:id) if hash.has_key?(:id)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES(?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(dog_hash)
    Dog.new(dog_hash).save
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, hash.fetch(:name), hash.fetch(:breed) )
    if !dog.empty?
      self.find_by_id(dog[0][0])
    else
      self.create(hash)
    end
  end

  def self.new_from_db(row)
    self.new({:name => row[1], :breed => row[2], :id => row[0]})
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    find_or_create_by({:name => row[1], :breed => row[2], :id => row[0]})
  end

  def update
    sql =<<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
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

end
