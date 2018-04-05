class Dog
  attr_accessor :name, :breed
  attr_reader :id

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
       breed TEXT
     );
     SQL
     DB[:conn].execute(sql)
   end

   def self.drop_table
     sql = "DROP TABLE IF EXISTS dogs"
     DB[:conn].execute(sql)
   end

   def save
     sql = "INSERT INTO dogs(name, breed) VALUES (?,?);"
     DB[:conn].execute(sql, [self.name, self.breed])
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     self
   end

   def self.create(attribute_hash)
     dog = self.new(name: attribute_hash[:name], breed: attribute_hash[:breed])
     dog.save
   end

   def self.find_by_id(n)
     sql = "SELECT * FROM dogs WHERE id = ?"
     row = DB[:conn].execute(sql, [n]).first
     self.new_from_db(row)
   end

   def self.find_or_create_by(name:, breed:)
     sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
     dog_arr = DB[:conn].execute(sql, name, breed)
     if !dog_arr.empty?
       dog_data = dog_arr.first
       dog = self.new_from_db(dog_data)
     else
       dog = self.create({name: name, breed: breed})
     end
     dog
   end

   def self.new_from_db(row)
     self.new(name: row[1], breed: row[2], id: row[0])
   end

   def self.find_by_name(name)
     sql = "SELECT * FROM dogs WHERE name = ?"
     row = DB[:conn].execute(sql, name).first
     self.new_from_db(row)
   end

   def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, [self.name, self.breed, self.id])
   end

end
