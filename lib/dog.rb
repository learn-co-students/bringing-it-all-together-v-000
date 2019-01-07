class Dog
  attr_accessor :name, :breed, :id
  
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
    self.new(name:row[1], breed:row[2], id:row[0])
  end
  
  def save
    if @id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].last_insert_row_id
      self
    end
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name=?, breed=?
      WHERE id=?
    SQL
    
    DB[:conn].execute(sql, @name, @breed, @id)
  end
  
  def self.create(args)
    new_dog = Dog.new(args)
    new_dog.save
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id=?
    SQL
    
    row = DB[:conn].execute(sql, id)[0]
    new_from_db(row)
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name=?
    SQL
    
    row = DB[:conn].execute(sql, name)[0]
    if row
      new_from_db(row)
    else
      false
    end
  end
  
  def self.find_or_create_by(args)
    found = find_by_name(args[:name])
    if found
      if found.breed == args[:breed]
        found
      else
        create(args)
      end
    else
      create(args)  
    end
  end
end