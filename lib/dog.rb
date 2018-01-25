require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
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
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.find_or_create_by(attributes)
    dog_zero = Dog.new(attributes)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", dog_zero.name, dog_zero.breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.find_by_id(dog_data[0])
    else
      dog = self.create(attributes)
    end
    dog
  end 

  def save
    if self.id
      self.update
    else
      sql=<<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
  end

  def self.new_from_db(row)
    attributes = {:id => row[0], :name => row[1], :breed => row[2]}
    new_dog = self.new(attributes)
    new_dog
  end

  def self.find_by_name(name)
    sql=<<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql=<<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql=<<-SQL
    UPDATE dogs SET
    name = ?,
    breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end










end