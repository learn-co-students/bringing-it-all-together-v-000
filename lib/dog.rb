require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name: name, breed: breed, id: id = nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)",self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(dog)
    self.new(name: dog[:name], breed: dog[:breed]).save
  end

  def self.find_by_id(num)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",num).flatten
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_or_create_by(dog)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",dog[:name], dog[:breed]).flatten
    if row.empty?
      new_dog = create(dog)
      new_dog
    else
      find_by_id(row[0])
    end
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name).flatten
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?",self.name, self.breed, self.id)
  end
end
