class Dog 
  
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed
  end 
  
  def self::create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT 
      )
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self::drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def save
    sql = <<-SQL
      INSERT INTO dogs 
      (name, breed)
      VALUES 
      (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self 
  end 
  
  def self::create(dog_hash)
    dog = Dog::new(dog_hash)
    dog.save
  end 
  
  def self::find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs 
      WHERE id = ?
    SQL
    
    dog_data = DB[:conn].execute(sql, id)[0]
    Dog::new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end 
  
  def self::find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    
    query = DB[:conn].execute(sql, name, breed)
    if !query.empty?
      data = query[0]
      Dog::new({id: data[0], name: data[1], breed: data[2]})
    else 
      Dog::create({name: name, breed: breed})
    end
  end 
  
  def self::new_from_db(row)
    Dog::new({id: row[0], name: row[1], breed: row[2]})
  end 
  
  def self::find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
    SQL
    
    row = DB[:conn].execute(sql, name)[0]
    Dog::new_from_db(row)
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