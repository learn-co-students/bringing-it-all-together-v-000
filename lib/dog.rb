
class Dog
  attr_accessor :breed, :name
  attr_reader :id
  
  def initialize(name:, breed:, id: nil)
    self.name = name 
    self.breed = breed
    @id = id
    self
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
    sql =  <<-SQL 
      DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql) 
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL
  
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end
  
  def self.create(name:, breed:)
    new(name: name, breed: breed).tap { |pup| pup.save }
  end
  
  def self.find_by_id(dogs_id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, dogs_id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name: name, breed: breed)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    
    dog_found = DB[:conn].execute(sql, name, breed)
    
    unless dog_found.empty?
      find_by_id(dog_found[0][0])
    else
      create(name: name, breed: breed)
    end
  end
  
  def self.new_from_db(row)
    new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(dogs_name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, dogs_name).map do |row|
      self.new_from_db(row)
    end.first
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