require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name, @breed, @id = name, breed, id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        ID INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name:name, breed:breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !row.empty?
      dog = self.new_from_db(row[0])
    else
      self.create(name:name, breed:breed)
    end
  end

  def self.new_from_db(row)
    Dog.new(name:row[1], breed:row[2], id:row[0])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
    self.new_from_db(row)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end
end
