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
        sql =  <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end
    
    def self.create(dog_hash)
      nu_dog = self.new(dog_hash)
      nu_dog.save
    end
    
    def self.all
      DB[:conn].execute("SELECT * FROM dogs").map do |x|
        dog_info = { name: x[1], breed: x[2], id: x[0] }
        Dog.create(dog_info)
      end
    end
    
    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
    def self.find_by_id(num)
      self.all.each {|x| return x if x.id == num.to_i}
    end
    
    
    def self.find_by_name(name)
      self.all.each {|x| return x if x.name == name}
    end
    
    def self.find_or_create_by(dog_hash)
      self.all.each {|x| return x if x.name == dog_hash[:name] && dog_hash[:breed] == x.breed}
      Dog.create(dog_hash)
    end
    
    def self.new_from_db(row)
      dog_hash = {
          id: row[0],
          name: row[1],
          breed: row[2]
      }
      self.create(dog_hash)
    end
      
        
    
end