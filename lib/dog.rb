require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
     SELECT * FROM dogs WHERE name = ?;
     SQL
     row = DB[:conn].execute(sql, name).first
     new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL
    row = DB[:conn].execute(sql, id).first
    new_from_db(row)
  end

  def save
    if self.id
      self.update
    else
      self.insert
    end
  end

  def self.create(hash)
    dog = Dog.new(name: hash[:name], breed: hash[:breed])
    dog.save
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, name, breed)
    binding.pry
    if !dog.empty
      self.find_by_id(self.find_by_name(hash[:name]).id)
    else
      self.create(hash)
    end
  end

end
