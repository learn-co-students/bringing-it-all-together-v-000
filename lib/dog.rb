class Dog 
  
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed 
    @id = id 
  end 
  
  def self.create_table 
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY, 
    name TEXT,
    breed TEXT)
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = <<-SQL
    DROP TABLE dogs 
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(row) 
  self.new(id:row[0], name:row[1], breed:row[2])
  end 
  
  def self.find_by_name(name)  
    sql = <<-SQL
    SELECT * 
    FROM dogs 
    WHERE name = ? 
    LIMIT 1 
    SQL
   
    DB[:conn].execute(sql, name).collect do |row|
      self.new_from_db(row)
    end.first 
  end 
  
  def self.find_by_id(id) 
    sql = <<-SQL
    SELECT * 
    FROM dogs 
    WHERE id = ? 
    LIMIT 1 
    SQL
   
    DB[:conn].execute(sql, id).collect do |row|
      self.new_from_db(row)
    end.first 
  end 
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * 
    FROM dogs 
    WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, name, breed)
    if row.empty?
      new_dog = self.create(name:name , breed:breed)
    else 
      new_dog = self.new_from_db(row.first)
    end
    new_dog
  end 
  
    def update 
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ? 
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end 
  
  def save 
  if self.id 
    self.update
  else
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)  
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
end 

def self.create(dog_info)
  self.new(dog_info).save
end 

end 