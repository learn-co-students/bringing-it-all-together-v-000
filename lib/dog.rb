class Dog
attr_accessor  :name, :breed, :id


    def initialize(input_hash)
      @id=input_hash[:id]
      @name=input_hash[:name]
      @breed=input_hash[:breed]
    end

    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
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
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end

    def self.create(input)
      new_dog=Dog.new(input)
      new_dog.save
    end

    def self.find_by_id(x)
      new_dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", x)[0]
      Dog.new(id: new_dog_array[0],name: new_dog_array[1],breed: new_dog_array[2])

    end

    def self.find_or_create_by(input_hash)
      result_of_search = DB[:conn].execute("SELECT id FROM dogs WHERE name = ? AND breed = ?", input_hash[:name], input_hash[:breed])

      if result_of_search != []
      found_id=result_of_search[0][0]
          self.find_by_id(found_id)
      else
        self.create(input_hash)
      end
    end

    def self.new_from_db(array)
      input_hash={}
      input_hash[:id]=array[0]
      input_hash[:name]=array[1]
      input_hash[:breed]=array[2]
      self.new(input_hash)
    end

    def self.find_by_name(name)
      found_dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
      self.new_from_db(found_dog_array)
    end

    def update
      self.save
    end
    
end
