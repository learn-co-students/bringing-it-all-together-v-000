class Dog
  attr_accessor :id, :name, :breed
  @@all = []

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
    @@all << self
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end

  def self.all
    @@all
  end

  def self.find_by_id(id)
    self.all.bsearch{|dog| dog.id == id}
  end

  def self.find_or_create_by(name:, breed:)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
     if !dog.empty?
       dog_new = Dog.new_from_db(dog[0])
     else
       dog_new = self.create(name: name, breed: breed)
     end
     dog_new
   end

   def self.new_from_db(row)
     Dog.new(id: row[0], name: row[1], breed: row[2])
   end

   def self.find_by_name(name)
     self.all.bsearch{|dog| dog.name == name}
   end

   def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end

end
