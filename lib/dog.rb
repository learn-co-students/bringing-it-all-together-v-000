require_relative '../config/environment.rb'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id = nil, name, breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql,@name,@breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(name:, breed:)
    dog = Dog.new(name,breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * from dogs
      WHERE dogs.id = ?
    SQL
    result = DB[:conn].execute(sql,id)[0]
    dog = Dog.new(result[0],result[1],result[2])
  end

  def self.find_or_create_by(name:,breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    result = DB[:conn].execute(sql,name,breed)
    if !result.empty?
      data = result[0]
      dog = self.new(data[0],data[1],data[2])
    else
      dog = self.create(name:name,breed:breed)
    end
  end

  def self.new_from_db(row)
    dog = Dog.new(row[0],row[1],row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql,@name,@breed,@id)
  end
end