class Dog

  #======== instance methods ========
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs ")[0][0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
  end

  #======== class methods ========
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
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.create(hash)       # hash.keys[1..-1].collect do |attribure_name|
    dog = self.new(hash)      #   self.send(attribure_name)
    dog.save                  # end
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"  #check to see if .flatten or [0] is better practice
    dog =  DB[:conn].execute(sql, id)[0]
    self.new_from_db(dog)
  end

  def self.new_from_db(dog)
    id = dog[0]                             #gets an array from database and assigns local variables
    name = dog[1]
    breed = dog[2]
    Dog.new(name: name, id: id, breed: breed)
  end

  def self.find_by_name(name)
    sql =  "SELECT * FROM dogs WHERE name = ?"
    dog = DB[:conn].execute(sql, name)[0]

    new_from_db(dog)
  end

  def self.find_or_create_by(hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten

    if !dog.empty?                #empty? is called because database returns an empty array //NOT A FALSY VALUE
      self.new_from_db(dog)
    else
     self.create(hash)
    end
  end
end
