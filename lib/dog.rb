class Dog 
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(id:nil, name:, breed:)
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
    sql = "DROP TABLE IF EXISTS dogs"
     DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(row)
    hash = {}
    hash[:name] = row[1]
    hash[:breed] = row[2]
    hash[:id] = row[0]
  new_dog = self.new(hash)
  new_dog
  end
  
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id:result[0], name:result[1], breed:result[2])
  end
  
  
    
    def save 
      if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end
    
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"

        dog = DB[:conn].execute(sql, id).first
        self.new_from_db(dog)
    end
    
def self.create(name:, breed:)
        new_dog = self.new(name:name, breed:breed)
        new_dog.save
        new_dog
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"

        dog = DB[:conn].execute(sql, name, breed)

        if dog.empty?
            self.create(name:name, breed:breed)
        else
            self.new_from_db(dog[0])
        end
    end
    
def update
sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
DB[:conn].execute(sql, self.name, self.breed, self.id)
end
end #of class