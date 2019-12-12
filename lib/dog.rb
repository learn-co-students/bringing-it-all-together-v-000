class Dog 
  
  attr_accessor :id, :name, :breed
  
 def initialize(id: nil, name: , breed: )
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql =<<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      type TEXT)
      SQL
      DB[:conn].execute(sql)
    end
    
  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs 
    SQL
    DB[:conn].execute(sql)
  end
  
  def save()
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
      #DB[:conn].execute("SELECT * FROM dogs ORDER by id DESC LIMIT 1")
    end
  end
  
  def self.create(name:, breed:)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
    
  def self.create(name: , breed: )
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = self.new(id: id, name: name, breed: breed)
    new_dog
  end
  
end