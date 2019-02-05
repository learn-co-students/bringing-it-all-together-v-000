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
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", attributes[:name], attributes[:breed])
    if !dog.empty?
      dog_data = dog[0]
      self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      self.create(attributes)
    end
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?;
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end