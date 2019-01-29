class Dog
  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id:nil)
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] #this returns an array within an array so have to specify these cells
    self
  end


  def self.create(name:, breed:)
    doggie = Dog.new(name: name, breed: breed)
    doggie.save
    doggie
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL
    out = DB[:conn].execute(sql, id).flatten
    dog = Dog.new(name: out[1], breed: out[2], id: out[0])
    dog
  end

  def self.find_or_create_by(name:, breed:)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
     if !dog.empty?
       dogdata = dog[0]
       dog = Dog.new(id: dogdata[0], name: dogdata[1], breed: dogdata[2])
     else
       dog = Dog.create(name: name, breed: breed)
     end
     dog
   end

   def self.new_from_db(row) #return instance from array, constructor
     dog = Dog.new(id: row[0], name: row[1], breed: row[2])
     dog
   end

   def self.find_by_name(name)
     sql = <<-SQL
     SELECT * FROM dogs
     WHERE name = ?
     LIMIT 1
     SQL
     dog = DB[:conn].execute(sql,name)[0]
  #   binding.pry
     self.new_from_db(dog)
   end

   def update #updating the database from change in instance
     sql = <<-SQL
     UPDATE dogs SET name = ?, breed = ? WHERE id = ?
     SQL
     DB[:conn].execute(sql,self.name, self.breed, self.id)
   end








end
