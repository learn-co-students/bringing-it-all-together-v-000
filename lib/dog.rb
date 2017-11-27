require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    hash = {id: row[0], name: row[1], breed: row[2]}
    dog = self.new(hash)
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    student = self.new(hash)
    student.save
    student
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    self.new_from_db(row)
  end

  def self.find_or_create_by(hash)
     song = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed]).flatten
     if !song.empty?
       hash = {id: song[0], name: song[1], breed: song[2]}
       self.new(hash)
     else
       create(hash)
     end
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    hash = {id: dog[0], name: dog[1], breed: dog[2]}
    self.new(hash)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
