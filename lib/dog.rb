require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(x)
    Dog.new(id: x[0], name: x[1], breed:x[2])
  end

  def self.find_by_name(x)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
    SQL
    d = DB[:conn].execute(sql, x).flatten
    self.new_from_db(d)
  end

  def self.find_by_id(x)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
    SQL
    d = DB[:conn].execute(sql, x).flatten
    self.new_from_db(d)
  end

  def self.create(x)
    dog = Dog.new(x)
    dog.save
  end

  def self.find_or_create_by(x)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, x[:name],x[:breed])
      if !dog.empty?
        dd = dog[0]
        dogo = self.new_from_db(dd)
      else
        dogo = self.create(x)
      end
      dogo
    end

  def update
    sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


  def save
    sql = <<-SQL
    INSERT INTO dogs
    (name, breed) VALUES(?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
end
