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
        id INT PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() from DOGS;")[0][0]
    self
  end
  
  def self.create(attributes)
    dog = self.new(name: attributes[:name], breed: attributes[:breed])
    dog.save
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL
    row = DB[:conn].execute(sql, id)[0]
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_or_create_by(attributes)
    if attributes[:id]
      self.find_by_id(attributes[:id])
    else
      self.create(attributes)
    end
  end
  
end