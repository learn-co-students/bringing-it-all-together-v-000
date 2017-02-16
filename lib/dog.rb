class Dog 

  attr_accessor :name, :breed 
  attr_reader :id

  def initialize(name: , breed: , id: nil)
    @name = name 
    @breed = breed 
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT 
      ) 
      SQL
      DB[:conn].execute(sql)
    end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save 
    sql = <<-SQL 
    INSERT INTO dogs(name, breed)
    VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] 
    self
    end

  def self.create(name: , breed: )
    dog = self.new(name: name, breed: breed)
    dog.save 
    dog
  end

  def self.find_by_id(given_id)
    sql = <<-SQL
      SELECT * FROM dogs 
      WHERE id = ?
      SQL
      
    row = DB[:conn].execute(sql, given_id).flatten
    self.new(name: row[1], breed: row[2], id: row[0])
    end 

  def self.find_or_create_by(name: , breed: )
    sql = <<-SQL 
    SELECT * FROM dogs 
    WHERE name = ? AND breed  = ?
    SQL
    result = DB[:conn].execute(sql, name, breed).flatten
    if !result.empty?
      dog = self.new(name: result[1], breed: result[2], id: result[0])
    else 
      dog = self.create(name: name, breed: breed)
    end 
    dog 
  end

  def self.new_from_db(row)
    flat_row = row.flatten
    new_dog = self.new(name: flat_row[1], breed: flat_row[2], id: flat_row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL 
    SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)
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