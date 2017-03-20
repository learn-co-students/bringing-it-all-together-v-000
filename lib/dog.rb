class Dog
attr_accessor :name , :breed, :id

def initialize(id: nil,name:,breed:)
  @id, @name,@breed = id, name, breed
end

def self.create_table
  DB[:conn].execute("CREATE TABLE  IF NOT EXISTS dogs(id INTEGER PRIMARY KEY,name text,breed text)")
end

def self.drop_table
DB[:conn].execute("DROP TABLE dogs")
end

def save
  if self.id == nil
  DB[:conn].execute("INSERT INTO  dogs (name , breed) VALUES(?,?)",self.name,self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
self # now we are returning our newly instantiated object
end

def self.create(name:,breed:)
  Dog.new(name:name,breed:breed).save
end

def self.find_by_id(id)
 dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",id)[0]
 #binding.pry
 Dog.new(id:dog[0],name:dog[1],breed: dog[2])
end

def self.find_or_create_by(name:,breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name,breed)
  if !dog.empty? # means if a record exist
    dog1 = dog[0]
     dog1 = Dog.new(id:dog1[0],name:dog1[1],breed:dog1[2])
   else
     dog1 = self.create(name: name, breed: breed)
   end
      dog1
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?,breed = ? WHERE id = ?",self.name,self.breed,self.id)
  end

  def self.new_from_db(row)
    Dog.new(id:row[0],name:row[1],breed:row[2])
  end
    
  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name)[0]
    dog_obj = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
    end
end