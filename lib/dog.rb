require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:,breed:,id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
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

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(dog_hash)
    dog = self.new(dog_hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    row=DB[:conn].execute(sql,id)[0]
    self.new_from_db(row)
  end

  def self.new_from_db(row)
    dog = self.new(id:row[0],name:row[1],breed:row[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?',name,breed)[0]
    if dog==nil
      dog = self.new(name: name, breed: breed)
      dog.save
      dog
    else
      self.find_by_id(dog[0])
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL
    dog = DB[:conn].execute(sql,name)[0]
    self.new_from_db(dog)
  end
  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end
end
