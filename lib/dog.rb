
class Dog 
  attr_accessor :name, :breed 
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @name = name 
    @breed = breed 
    @id = id 
  end 
  
  def self.create_table
    sql =<<-SQL 
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
  
  def self.new_from_db(array)
    self.new(id: array[0], name: array[1], breed: array[2])
  end 
  
  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap do |dog|
      dog.save
    end 
  end 
  
  def self.find_by_name(name)
    sql =<<-SQL 
        SELECT * 
        FROM dogs
        WHERE dogs.name = ?
    SQL
    
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end 
  
  def self.find_by_id(num)
    sql =<<-SQL
        SELECT *
        FROM dogs 
        WHERE dogs.id = ?
    SQL
    
    self.new_from_db(DB[:conn].execute(sql, num).flatten)
  end 
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
        SELECT *
        FROM dogs 
        WHERE dogs.name = ? AND dogs.breed = ?
    SQL
    
    dog = DB[:conn].execute(sql, name, breed)
    
    if !dog.empty?
      self.new_from_db(dog[0])
    else 
      self.create(name: name, breed: breed)
    end 
  end 
  
  def update 
    sql =<<-SQL
        UPDATE dogs 
        SET name = ?, breed = ?
        WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def save 
    if self.id 
      self.update 
    else 
      sql =<<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self 
    end 
  end 
end 