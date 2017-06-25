require 'pry'
class Dog
   attr_accessor :name, :breed, :id


   def initialize(hash)
     @name = hash[:name]
     @breed = hash[:breed]
     @id = nil
   end

   def self.create_table
     sql = <<-SQL
       CREATE TABLE IF NOT EXISTS dogs (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         name TEXT,
         grade INTEGER
       )
     SQL
     DB[:conn].execute(sql)
   end

   def self.drop_table
     sql = <<-SQL
       DROP TABLE dogs
     SQL
     DB[:conn].execute(sql)
   end

   def save
     sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?, ?)
     SQL

     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

     return self
   end

   def self.create(hash)
     dog = self.new(hash)
     dog.save
     return dog
   end

   def self.find_by_id(id)
     sql = <<-SQL
       SELECT * FROM dogs WHERE id = #{id}
     SQL
     dog = DB[:conn].execute(sql)[0]

     hash = {:name=>dog[1], :breed=>dog[2]}
     new_dog = self.new(hash)
     new_dog.id = id
     return new_dog
   end

   def self.find_or_create_by(hash)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
     if !dog.empty?
       data = dog[0]
       dog = Dog.new_from_db(data)
       return dog
     else
       dog = self.create(name: hash[:name], breed: hash[:breed])
       return dog

     end
   end

   def self.new_from_db(row)
      dog = self.new(:name=>row[1], :breed=>row[2])
      dog.id = row[0]
     return dog
   end

   def self.find_by_name(name)
     data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]

     dog = Dog.new_from_db(data)
     return dog
   end

   def update
     update = DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)[0]
   end

end
