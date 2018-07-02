class Dog
  attr_accessor :breed, :name, :id
  
  def initialize(name:, breed:, id: nil)
    self.name = name 
    self.breed = breed
    self.id = id
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
    
  end
  
  def new_from_db
  end
  
  def find_by_name
  end
  
  def update
  end
  
end