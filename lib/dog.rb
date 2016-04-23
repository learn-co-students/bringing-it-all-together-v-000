class Dog
attr_accessor :name, :breed, :id
  def initialize(hash)
   @id = nil
    hash.each do |property, value|
    self.send("#{property}=", value)
    end
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
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
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  end

   def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    hashresult = {}
    hashresult[:id] = result[0]
    hashresult[:name] = result[1]
    hashresult[:breed] = result[2]
    Dog.new(hashresult)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    hashresult = {}
    hashresult[:id] = result[0]
    hashresult[:name] = result[1]
    hashresult[:breed] = result[2]
    Dog.new(hashresult)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
        dog_data = {}
        dog_data[:id] = dog[0][0]
        dog_data[:name] = dog[0][1]
        dog_data[:breed] = dog[0][2]
      dog = Dog.new(dog_data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
   # self.new is the same as running Song.new
        dog_data = {}
        dog_data[:id] = row[0]
        dog_data[:name] = row[1]
        dog_data[:breed] = row[2]
    print  dog_data
     new_dog = self.new(dog_data)
  new_dog  # return the newly created instance
end
end