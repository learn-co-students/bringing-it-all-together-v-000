class Dog
   attr_accessor :name, :breed, :id
   def initialize name: nil, breed: nil, id: nil
      @name=name;@breed=breed;@id=id
   end

   def self.create_table
     sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
   end

   def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
   end

   def update
      DB[:conn].execute("UPDATE dogs SET name=? WHERE id=?",@name,@id)
      DB[:conn].execute("UPDATE dogs SET breed=? WHERE id=?",@breed,@id)
   end
   
   def save
      if @id!=nil
         update
      else
         DB[:conn].execute("INSERT INTO dogs(name, breed) VALUES (?,?)",@name,@breed)
         @id=DB[:conn].execute("SELECT COUNT(id) FROM dogs")[0][0]
      end
      self
   end
   
   def self.create h
     self.new(h).save
   end
   
   def self.new_from_db r
     self.new(id:r[0],name:r[1],breed:r[2])
   end
   
   def self.find_by_id i
      new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id IS ?", i)[0])
   end
   
   def self.find_or_create_by name:, breed:
      r=DB[:conn].execute("SELECT * FROM dogs WHERE name IS ? AND breed IS ?",name,breed)[0];
      if r!=nil
        new_from_db(r)
      else
        create({name: name, breed: breed})
      end
   end
   
   def self.find_by_name s
      new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name IS ?", s)[0])
   end
end

    