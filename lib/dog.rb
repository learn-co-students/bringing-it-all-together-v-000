require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(dog_hash, id = nil)
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    a = self.new(hash)
    a.save
  end

  def self.find_by_id(id)
    dog_hash = {}
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog_hash[:name] = DB[:conn].execute(sql, id)[0][1]
    dog_hash[:breed] = DB[:conn].execute(sql, id)[0][2]
    dog_hash[:id] = id

    a = self.new(dog_hash)
    a.id = id
    a
  end

  def self.find_or_create_by(hash)
    sql = "SELECT * FROM dogs WHERE name = ?"
    find = DB[:conn].execute(sql, hash[:name]
    if !find.empty?
      binding.pry

      found_dog = find[0]
      binding.pry
      new_dog = self.new
    end


  end




end
