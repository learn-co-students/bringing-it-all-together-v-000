class Dog
  attr_accessor :id, :name, :breed
  def initialize (id:nil, name:, breed:)
    @id=id
    @name=name
    @breed=breed
  end
  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
  def self.new_from_db(row)

      new_dog=self.new(id:row[0],name:row[1],breed:row[2])
      # new_dog.id=row[0]
      # new_dog.name=row[1]
      # new_dog.breed=row[2]
      new_dog


    end
    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM dogs WHERE name= ? LIMIT 1", name).map do |row|
          self.new_from_db(row)
        end.first

      end
    def update
      DB[:conn].execute("UPDATE dogs SET name=? WHERE id=?",self.name,self.id)
    end
    def save
      if self.id
        self.update
      else
        DB[:conn].execute("INSERT INTO dogs (name,breed) VALUES (?,?)",self.name,self.breed)
      end
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
    def self.create(name:,breed:)
      new_dog=self.new(name: name,breed: breed)
      new_dog.save
      new_dog
    end
    def self.find_by_id(id)
      DB[:conn].execute("SELECT * FROM dogs WHERE id= ? LIMIT 1", id).map do |row|
        self.new_from_db(row)
      end.first
    end
    def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

  if !dog.empty?
    dog_data = dog[0]
    dog = Dog.new(id:dog_data[0],name: dog_data[1],breed: dog_data[2])

  else
    dog = self.create(name: name, breed: breed)
  end
  dog
end
end
