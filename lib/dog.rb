class Dog

attr_accessor :name, :breed
attr_reader :id

 def initialize(name:, breed:, id: nil)
   @id = id
   @name = name
   @breed = breed
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
   sql = "DROP TABLE dogs"
   DB[:conn].execute(sql)
 end

 def self.new_from_db(row)
   x = self.new(name: row[1], breed: row[2], id: row[0])
   x
 end

 def self.find_by_name(name)
   sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
   row = DB[:conn].execute(sql, name).flatten
   x = new_from_db(row)
   x
 end

 def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed, self.id)
 end

 def self.create(name:, breed:)
   #{name => "yo", breed => "dog, id => 5"}
   x = self.new(name: name, breed: breed)
   x.save
   x
 end

 def save
   if self.id
     self.update
   else
     sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC limit 1")[0][0]
   end
   self
 end

 def self.find_by_id(x)
   sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
   row = DB[:conn].execute(sql, x).flatten
   n = self.new_from_db(row)
   n
 end

 def self.find_or_create_by(name: ,breed:)
   dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
   if !dog.empty?
         dog_info = dog[0]
         dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
       else
         dog = self.create(name: name, breed: breed)
       end
       dog
 end
end
