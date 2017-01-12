require_relative '../config/environment.rb'
require 'pry'


class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    id = nil
    attributes.each {|key, value| self.send(("#{key}="), value)}
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

  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id=?
    SQL

    dog_row = DB[:conn].execute(sql,id)
    new_dog = Dog.new(id: dog_row[0][0], name: dog_row[0][1], breed: dog_row[0][2])
    new_dog

  end

  def self.find_by_name(name)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name=?
    SQL

    dog_row = DB[:conn].execute(sql,name)
    new_dog = Dog.new(id: dog_row[0][0], name: dog_row[0][1], breed: dog_row[0][2])
    new_dog

  end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

  def self.find_or_create_by(attributes)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog_row = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

    if !dog_row.empty?
      new_dog = Dog.new_from_db(dog_row[0])
    else
      new_dog = Dog.create(attributes)
    end

    new_dog
    #binding.pry

  end

  def save

    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self

  end

end
