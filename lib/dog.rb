#####attributes
#has a name and a breed
# has an id that defaults to `nil` on initialization
#accepts key value pairs as arguments to initialize
#####::create_table
#creates the dogs table in the database
#####::drop_table
#drops the dogs table from the database
#####save
#returns an instance of the dog class
#saves an instance of the dog class to the database and then sets the given dogs `id` attribute
#####::create
#takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database
#returns a new dog object
#####::find_by_id
#returns a new dog object by id
#####::find_or_create_by
#creates an instance of a dog if it does not already exist
#when two dogs have the same name and different breed, it returns the correct dog
#when creating a new dog with the same name as persisted dogs, it returns the correct dog
#####::new_from_db
#creates an instance with corresponding attribute values
#####::find_by_name
#returns an instance of dog that matches the name from the DB
#####update
#updates the record associated with a given instance

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
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
     sql = <<-SQL
     DROP TABLE IF EXISTS dogs
     SQL
     DB[:conn].execute(sql)
   end

   def save
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
     end
   end

   def self.create(name:, breed:)
     dog = Dog.new(name: name, breed: breed)
     dog.save
     dog
   end

   def self.find_by_id(id)
     sql = "SELECT * FROM dogs WHERE id = ?"
     result = DB[:conn].execute(sql, id)[0]
     self.new_from_db(result)
   end

   def self.find_by_name(name)
     sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE name = ?
       LIMIT 1
     SQL
     DB[:conn].execute(sql, name).map do |row|
       self.new_from_db(row)
     end.first
   end

   def self.find_or_create_by(name:, breed:)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
     if !dog.empty?
       data = dog[0]
       dog = Dog.new(id: data[0], name: data[1], breed: data[2])
     else
       dog = self.create(name: name, breed: breed)
     end
     dog
   end

   def self.new_from_db(row)
     self.new(id: row[0], name: row[1], breed: row[2])
   end

   def update
       sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
       DB[:conn].execute(sql, self.name, self.breed, self.id)
   end
end
