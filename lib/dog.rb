class Dog
attr_accessor :name, :breed
attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql="CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
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
      self
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id_num)
    sql = "SELECT * FROM dogs WHERE id=?"
    DB[:conn].execute(sql, id_num).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name=? AND breed=?"
    data = DB[:conn].execute(sql, name, breed)
    if !data.empty?
      dog_data = data[0]
      new_dog = self.new_from_db(dog_data)
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name=? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = Dog.new(name: name, breed: breed, id: id)
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
