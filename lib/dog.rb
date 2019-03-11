class Dog
attr_accessor :name, :breed
attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
       id INTEGER PRIMARY KEY,
       name TEXT,
       breed TEXT
    )"
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
      self
    end
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  #def self.new_from_db(row)
    #id, name, breed = row[0], row[1], row[2]
    #self.new(id, name, grade)
  #end

  def self.find_by_id(id)
   sql = "SELECT * FROM dogs WHERE id = ?"
   result = DB[:conn].execute(sql, id)[0]
   Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new(dog_data[0], dog_data[1], dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    self
  end
end
