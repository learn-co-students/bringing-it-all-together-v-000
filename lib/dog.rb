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

def self.create(dog_hash)
  Dog.new(dog_hash).save
end

def self.find_by_id(id)
 dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",id)[0]
 #binding.pry
 Dog.new(id:dog[0],name:dog[1],breed: dog[2])
end
end