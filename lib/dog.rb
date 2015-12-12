require 'pry'

class Dog

  attr_reader :id
  attr_accessor :name, :breed

  def initialize(name, breed, id = nil)
    @name = name
    @breed = breed
    @id = id
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(row)
    dog = Dog.new(row[:name],row[:breed])
    dog.save
    dog
  end

  def self.new_from_db(row)
    new_dog = self.new(row[1],row[2],row[0])
  end
 

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,id).collect do |row|
      new_from_db(row)
    end.first
  end

  def self.find_or_create_by(row)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{row[:name]}' AND breed = '#{row[:breed]}'")
    if !dog.empty?
      dog = Dog.new(dog[0][1],dog[0][2],dog[0][0])
    else
      dog = self.create(row)
    end
    dog
  end

  def self.find_by_name(name)
      sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,name).collect do |row|
      new_from_db(row)
    end.first

  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 

end