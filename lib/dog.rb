class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    
    dog_array = DB[:conn].execute(sql, id).first
    new_dog = self.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    
    all_dogs = DB[:conn].execute(sql, name, breed)
    
    if !all_dogs.empty?
      dog_array = all_dogs[0]
      new_dog = self.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    
    dog_array = DB[:conn].execute(sql, name).first
    new_dog = self.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
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