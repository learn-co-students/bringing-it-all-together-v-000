
class Dog
  attr_accessor :name, :breed, :id

  #initializes dog objects from a hash
  def initialize(dog_hash)
    @name=dog_hash[:name]
    @breed=dog_hash[:breed]
    @id=dog_hash[:id]
  end

  #creates the database table
  def self.create_table
    sql="CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)" #forgot to check if it exists!
    DB[:conn].execute(sql)
  end

  #drops the table (as if it were hot)
  def self.drop_table
    sql="DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  #creates a new object from a database row (object array)
  def self.new_from_db(row)
    Dog.new({name:row[1],breed:row[2],id:row[0]})
  end

  #returns an already-persisted object based on the stored array from the database
  def self.find_by_name(name)
    sql="SELECT * FROM dogs WHERE name=?"
    row=DB[:conn].execute(sql,name).flatten
    Dog.new_from_db(row)
  end


  #updates the database row for already-persisted object row
  def update
    sql="UPDATE dogs SET name=?, breed=? WHERE id=?"
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

  def self.find_by_id(id)
    sql="SELECT * FROM dogs WHERE id=?"
    doggoray=DB[:conn].execute(sql,id).flatten
    dog=Dog.new_from_db(doggoray)
    dog
  end

  def self.find_or_create_by(dog_hash) #struggled with this, thought it was passing in arguments, but it was a single hash!
    sql="SELECT * FROM dogs WHERE name=? AND breed=?"
    data=DB[:conn].execute(sql,dog_hash[:name],dog_hash[:breed])
    if !data.empty?
      dog_data=data[0]
      dog=Dog.new_from_db(dog_data)
      dog
    else
      dog=self.create(dog_hash)
    end
    dog
  end




  #Instance method
  #saves changes (if already persisted) or new object to database
  #returns nil or an id number for a new row
  def save
    if self.id   #if the ID is set, it's already been persisted
      self.update #so update it
    else
      sql="INSERT INTO dogs(name,breed) VALUES(?,?)" #if not, make a new one
      DB[:conn].execute(sql,self.name,self.breed)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] #update the object's id so it can be found later
    end
    self   #!Forgot to return Dog object!
  end

  def self.create(dog_hash)
    dog=Dog.new(dog_hash)
    dog.save
    dog
  end


end
