class Dog 
attrs = {
  :id => "INTEGER PRIMARY KEY",
  :name => "TEXT",
  :breed => "TEXT"
}

  # ATTRIBUTES.keys.each do |key|
  #   attr_accessor key
  # end
 attr_accessor :name, :breed, :id

  def initialize( id:nil, name:, breed:)
    @name = name 
    @breed = breed 
    @id = id
  end
  
  def self.create_table
    sql = %{
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
    }
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = %{
      DROP TABLE IF EXISTS dogs
    }
    DB[:conn].execute(sql)
  end
  
   def save
    if self.id
      self.update
    else 
    
     sql = %{
       INSERT INTO dogs (name, breed) 
       VALUES (?, ?)
     }
     sql_select = %{
       
       SELECT * FROM dogs 
       WHERE id = (SELECT MAX(id) FROM dogs)
     }
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute(sql_select, id)[0][0]
    end
    self
  end
    
  def self.new_from_db(row)
    new_doggo = Dog.new(name:"bob", breed:"lab")
    new_doggo.id = row[0]
    new_doggo.name =  row[1]
    new_doggo.breed = row[2]
    new_doggo 
  end

  
  def update
    sql = %{UPDATE dogs 
    SET name = ?, breed = ? WHERE id = ?
    }
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.create(attrs)
    new_dog = Dog.new(attrs)
    new_dog.save
    new_dog
  end
 
  
   def self.find_by_id(id)
    sql = %{
      
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
      
     }

    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name:, breed:)
      sql = %{
            SELECT *
            FROM dogs
            WHERE name = ?  
            AND breed = ?
            LIMIT 1
      }
  
      dog = DB[:conn].execute(sql,name,breed)
  
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
        dog = self.create(name: name, breed: breed)
      end
      dog
    end
    
    def self.find_by_name(name)
    sql = %{
      
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
      
     }

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
end 
