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

   def self.new_from_db(row)
     id = row[0]
     name = row[1]
     breed = row[2]
     dog = Dog.new(name: name, breed: breed, id: id)
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

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
      SQL

      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end
    end

    def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      new_dog = dog[0]
      dog = Dog.new(new_dog[1], new_dog[2], new_dog[0])
    else
      dog = self.create(name: name, breed: breed)
    end
  end



end
