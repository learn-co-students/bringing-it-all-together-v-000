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
  
  def self.find_or_create_by(:name, :breed)
    dog = DB[:conn].execute
    
  end 
end 