class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    
    sql = <<-SQL
      CREATE TABLE dogs (
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
    dog = new(id: row[0], name: row[1], breed: row[2])
    dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from dogs WHERE name = ?
    SQL
    
    row = DB[:conn].execute(sql, name)
    dog = new_from_db(row[0])
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.create(name:, breed:)
    dog = new(name: name, breed: breed)
    dog.save
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * from dogs WHERE id = ?
    SQL
    
    row = DB[:conn].execute(sql, id)
    
    dog = new_from_db(row[0])
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * from dogs WHERE name = ? AND breed = ?
    SQL
    
    row = DB[:conn].execute(sql, name, breed)
    
    if row[0]
      new_from_db(row[0])
    else
      create(name: name, breed: breed)
    end
  end
end