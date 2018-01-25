require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
          SQL
    DB[:conn].execute(sql)

  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    Dog.new_from_db(DB[:conn].execute("SELECT * FROM dogs where id = id").first)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      Dog.new_from_db(dog[0])
    else
      Dog.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    Dog.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = name")[0])
  end
    
  def update
    sql = <<-SQL
          UPDATE dogs SET name = ?, breed = ? WHERE id = ? 
          SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)  
  end
end