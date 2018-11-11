class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
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
    @id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ?", self.name)[0][0]
    self
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0],name: row[1],breed: row[2])
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    
    Dog.new_from_db(DB[:conn].execute(sql, name)[0])
  end
    
  
end