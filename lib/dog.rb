class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  
  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end #initialize
  
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL
    
    DB[:conn].execute(sql)
  end #.create_table
  
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end #.drop_table
  
  
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
    end #if self.id
    self
  end #save
  
  
  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end #.create
  
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end #.new_from_db
  
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
  end #.find_by_name
  
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end # if !dog.empty?
    dog
  end #find_or_create_by
  
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
  end #.find_by_id
  
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end #update
  
end #Class Dog