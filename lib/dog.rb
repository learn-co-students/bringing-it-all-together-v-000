require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table

    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INT PRIMARY KEY,
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

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    #binding.pry
    dog = self.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql,id)[0]
    dog_o = self.new(id: dog[0],name: dog[1],breed: dog[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    #binding.pry
    dog_a = DB[:conn].execute(sql, name,breed)

    if !dog_a.empty?
      dog_data = dog_a[0]
      dog = self.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      dog = self.create(name:name, breed:breed)
    end
  end

  def self.new_from_db(row)
    dog = self.new(id:row[0],name:row[1],breed:row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    dog = DB[:conn].execute(sql,name)[0]
    dog_o = self.new(id: dog[0],name: dog[1],breed: dog[2])
  end
end
