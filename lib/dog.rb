require_relative "../config/environment.rb"
class Dog

  attr_accessor :name, :breed, :id


    def initialize (hash)
     hash.each {|key, value| self.send(("#{key}="), value)}
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
      sql = "DROP TABLE IF EXISTS dogs;"
      DB[:conn].execute(sql)
    end

    def save
      sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL

      DB[:conn].execute(sql, @name, @breed)

      @id= DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

    def self.create(hash)
      new_dog = Dog.new(hash)
      new_dog.save
      new_dog
    end

    def self.find_by_id(num)
      sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
            SQL

     self.new_from_db(DB[:conn].execute(sql, num).first)
    end

    def self.new_from_db(array)
     new_dog = Dog.new({id: array[0], name: array[1], breed: array[2]})
     new_dog
    end

    def self.find_or_create_by(hash)
      sql= "SELECT * FROM dogs WHERE name = ? AND breed = ?"
      dog= DB[:conn].execute(sql, hash[:name], hash[:breed])
      if !dog.empty?
        self.find_by_id(dog[0][0])
      else
        self.create(hash)
      end
    end

    def self.find_by_name(name)
      sql= <<-SQL
           SELECT *
           FROM dogs
           WHERE name = ?
           SQL

      self.new_from_db(DB[:conn].execute(sql, name).first)
    end

    def update
      sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ? WHERE id = ?
            SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end





