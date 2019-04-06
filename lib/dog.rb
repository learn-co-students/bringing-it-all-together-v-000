require 'pry'
class Dog 

attr_accessor :name, :breed, :id 

  def initialize(attributes)
    @name = attributes[:name] 
    @breed = attributes[:breed]
    @id = attributes[:id ]
  end
  
  def self.create_table
    sql = "CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT 
      );"
     DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
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
  
  def self.create(attributes) 
    dog = Dog.new(attributes)
    dog.save 
    dog 
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs 
          WHERE id = ?"
    dog_info = DB[:conn].execute(sql, id)[0]
    dog_info_hash = {:id => dog_info[0], :name => dog_info[1], :breed => dog_info[2]}
    dog = Dog.new(dog_info_hash)
  end
  
  def self.find_or_create_by(dog_info)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, dog_info[:name], dog_info[:breed])[0]
    if dog != nil
      dog_info[:id] = dog[0]
      dog = Dog.new(dog_info)
    else
      dog = Dog.create(dog_info)
    end
    return dog 
  end
  
  def self.new_from_db(dog)
    dog_info = {:id => dog[0], :name => dog[1], :breed => dog[2]}
    new_dog = Dog.new(dog_info) 
  end
  
  def self.find_by_name(name)
         sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
     
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? 
          WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
end 