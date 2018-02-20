class Dog 
  attr_accessor :id, :name, :breed
  def initialize(id: nil, name:, breed:)
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
      )
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
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    #newdog = 
    self
  end
  
  def self.create(hashattr)
    dog = Dog.new(name: hashattr[:name], breed: hashattr[:breed])
    dog.save
    dog
    # {:name=>"Ralph", :breed=>"lab"}
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs 
      WHERE id = ?
    SQL
    
    vals = DB[:conn].execute(sql, id)
    
    vals.flatten!
    newhash = {name: vals[1], breed: vals[2]}
    self.create(newhash)
    # binding.pry
    # expects an instance of Dog
  end
end