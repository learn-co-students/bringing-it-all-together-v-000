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
    
    vals = DB[:conn].execute(sql, id)[0]
    # newhash = {id: vals[0], name: vals[1], breed: vals[2]}
    # dog = self.create(newhash)
    return Dog.new(id: vals[0], name: vals[1], breed: vals[2])
    #binding.pry
    # expects an instance of Dog
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    
    dbvals = DB[:conn].execute(sql, name, breed)
    
    if !dbvals.empty?
      return self.find_by_id(dbvals[0][0])
    else 
      return self.create({name: name, breed: breed})
    end
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog.save
    dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    
    dog = DB[:conn].execute(sql, name)[0]
    Dog.new(id: dog[0], name: dog[1], breed: dog[2])
  end
  
  def update
    # binding.pry
    sql = <<-SQL
      UPDATE dogs
      SET id = ?, name = ?, breed = ?
    SQL
    
    DB[:conn].execute(sql, self.id, self.name, self.breed)
  end
end