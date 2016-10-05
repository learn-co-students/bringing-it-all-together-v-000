require "pry"
class Dog
  attr_accessor :name, :breed, :id
  #attr_reader :id

  def initialize(attributes)
    attributes.each do |key, value|
      self.send(("#{key}="),value)
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    dog = DB[:conn].execute(sql, name)
    self.new_from_db(dog.first)
  end

  def save
    if self.id == nil
      sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      update
    end
    self
  end

  def update

    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.create(attributes)
    Dog.new(attributes).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql,id)
    self.new_from_db(dog.first)
  end

  def self.find_or_create_by(attributes)
    #binding.pry
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).first
    #binding.pry
    if dog == nil
      self.create(attributes)
    else
      self.find_by_id(dog.first)
    end

    end





end
