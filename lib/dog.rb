require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:)
    @name = name
    @breed = breed
  end

  def initialize(hash)
    hash.each do |k,v|
      instance_variable_set("@#{k}",v) unless v.nil?
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
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
      INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
      dog = Dog.new(hash)
      dog.save
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    Dog.create({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE dogs.id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE dogs.name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    Dog.create({id: row[0], name: row[1], breed: row[2]})
  end


  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      row = dog[0]
      Dog.create({id: row[0], name: row[1], breed: row[2]})
    else
      Dog.new(name: name, breed: breed).save
    end
  end

end
