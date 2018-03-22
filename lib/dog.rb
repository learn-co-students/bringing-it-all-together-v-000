class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
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
    dog = Dog.new(name: name, breed: breed) #why is it written like this? it's not in the notes
    dog.save
    dog
  end

  def self.find_by_id(id)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    dog
  end

  def self.find_or_create_by(name:, breed:)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if !dog_data.empty?
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

end
