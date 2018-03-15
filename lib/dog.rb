require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  @@all = []

  def initialize(hash, id = nil)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = id
    @@all << self
  end

  def self.create_table
    sql=<<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql=<<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save #FIX
      if self
        sql=<<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        self
      end
  end #save

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)
    if id == dog[0][0]
      self.new_from_db(dog.flatten)
    end
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      new_dog = self.new(hash, dog[0][0])
      new_dog
    else
      self.create(hash)
    end
  end #method

  def self.new_from_db(attribute)
    hash = {name: attribute[1], breed: attribute[2]}
    new_dog = self.new(hash, attribute[0])
    new_dog
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    hash = {name: dog[0][1], breed: dog[0][2]}

    if !dog.empty?
      new_dog = self.new(hash, dog[0][0])
      new_dog
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end #class
