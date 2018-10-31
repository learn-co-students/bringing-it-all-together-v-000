class Dog
  attr_accessor :name, :breed, :id
  
  #initialize has to accept hash/keyword argument/key-value pairs
  def initialize (name:, breed:, id: nil)
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
      DROP TABLE IF EXISTS dogs
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
    #and make sure to return dog instance!
    return self #don't have to use return
  end
  
  def self.create(name:, breed:)
    created_dog = Dog.new(name: name, breed: breed)
    created_dog.save
    created_dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    
    found_dog = DB[:conn].execute(sql,id).flatten
    n_id = found_dog[0]
    n_name = found_dog[1]
    n_breed = found_dog[2]
    
    dog = Dog.new(id: n_id, name: n_name, breed: n_breed)
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL
    #dog_found = DB[:conn].execute(sql, name:, breed:)
    dog_found = DB[:conn].execute(sql, name, breed)
    if !dog_found.empty?
      d_id = dog_found[0][0]
      d_name = dog_found[0][1]
      d_breed = dog_found[0][2]
      dog = Dog.new(id: d_id, name: d_name, breed: d_breed)
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
    #binding.pry
  end
  
  def self.new_from_db(items)
    d_id = items[0]
    d_name = items[1]
    d_breed = items[2]
    Dog.new(id: d_id, name: d_name, breed: d_breed)
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    dog_found = DB[:conn].execute(sql, name)
    dog = self.new_from_db(dog_found.flatten)
    #binding.pry
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