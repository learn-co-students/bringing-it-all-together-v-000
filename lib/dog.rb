require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  @@all = []
  
  def initialize(name:, breed:, id: nil)
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
      );
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
    binding.pry
    new_dog = self.new(name = row[1], breed = row[2], id = row[0])
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  
  def self.create(attributes_hash)
  
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end