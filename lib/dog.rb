require 'pry'
class Dog

    attr_accessor :name, :breed, :id

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
      );
     SQL

     DB[:conn].execute(sql)
   end

   def self.drop_table
     sql = "DROP TABLE dogs"

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
     end
     self
   end

   def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end

   def self.create(name:, breed:)
     dog = Dog.new(name: name, breed: breed)
     dog.save
     dog
   end

    def self.find_by_id(num)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, num).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    dog = self.new(row[1], row[2], row[0])
    dog
  end

end
