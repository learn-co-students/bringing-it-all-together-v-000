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
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def save
    if self.id 
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
  
  def self.create(hash)
    self.new(name: hash[:name], breed: hash[:breed]).save
  end
  
  def self.find_by_id(dog_id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", dog_id).flatten
    self.new_from_db(dog)
  end 
  
  def self.find_or_create_by(name:, breed:)
    dog_att = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog_att.empty?
      dog = dog_att[0]
      doggo = self.new_from_db(dog)
    else
      doggo = self.create(name: name, breed: breed)
    end
    doggo
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    self.new_from_db(dog)
  end
  
  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed =?", self.name, self.breed)
  end 
  
end