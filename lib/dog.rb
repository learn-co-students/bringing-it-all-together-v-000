require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save

    sql = <<-SQL
    INSERT INTO dogs
    (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.create(name:, breed:)
    Dog.new(name: name, breed: breed).tap{|dog| dog.save}
  end


  def save

    sql = <<-SQL
    INSERT INTO dogs
    (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.find_by_id(id)

    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?;
    SQL

    DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}[0]
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)

    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
  end

  def update

    sql = <<-SQL
    UPDATE dogs
    SET
    name = ?,
    breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name_and_breed(name, breed)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    AND
    breed = ?
    SQL

    DB[:conn].execute(sql, name, breed).map{|row| self.new_from_db(row)}.first
  end

  def self.find_or_create_by(name:, breed:)

    if self.find_by_name_and_breed(name, breed)
      self.find_by_name_and_breed(name, breed)
    else
      self.create(name: name, breed: breed)
    end

  end

end
