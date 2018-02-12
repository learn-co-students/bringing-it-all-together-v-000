require 'pry'
class Dog
   attr_accessor :name, :breed, :id

   def initialize(attributes)
      attributes.each {|key, value| self.send(("#{key}="), value)}
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
     sql = <<-SQL
       DROP TABLE dogs
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
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM  dogs")[0][0]
      end
      self
   end

   def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
   end

   def self.create(attributes)
      dog = Dog.new(attributes)
      dog.save
      dog
   end

   def self.find_by_id(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      res = DB[:conn].execute(sql, id).flatten
      attributes = {}
      attributes[:id] = res[0]
      attributes[:name] = res[1]
      attributes[:breed] = res[2]
      dog = Dog.new(attributes)
      dog
   end

   def self.find_or_create_by(name:, breed:)
      attributes = {}
      res = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !res.empty?
        res_data = res[0]
        attributes[:id] = res_data[0]
        attributes[:name] = res_data[1]
        attributes[:breed] = res_data[2]
        res = Dog.new(attributes)
      else
        attributes[:name] = name
        attributes[:breed] = breed
        res = self.create(attributes)
      end
      res
    end 

    def self.new_from_db(row)
      attributes = {}
      attributes[:id] = row[0]
      attributes[:name] = row[1]
      attributes[:breed] = row[2]
      dog = self.new(attributes)
      dog
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ?"
      res = DB[:conn].execute(sql, name).flatten
      attributes = {}
      attributes[:id] = res[0]
      attributes[:name] = res[1]
      attributes[:breed] = res[2]
      dog = self.new(attributes)
      dog
    end
end