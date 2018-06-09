class Dog
  attr_accessor :name, :breed, :id

  def initialize(options = {})
    options.each {|k, v| self.instance_variable_set("@#{k}", v)}
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(data_hash)
    new_dog = self.new(data_hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.id = ?", id)[0]
    new_dog = self.new
    new_dog.id, new_dog.name, new_dog.breed = dog_data[0], dog_data[1], dog_data[2]
    new_dog
  end

  def self.find_or_create_by(options = {})
    name = options[:name]
    breed = options[:breed]

    sql = "SELECT * FROM dogs WHERE dogs.name = ? AND dogs.breed = ?"
    result = DB[:conn].execute(sql, name, breed)
    if result.empty?
      self.create(options)
    else
      self.find_by_id(result[0][0])
    end
  end

  def self.new_from_db(row)
    new_dog = self.new
    new_dog.id, new_dog.name, new_dog.breed = row[0], row[1], row[2]
    new_dog
  end

  def self.find_by_name(name)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE dogs.name = ?", name)[0]
    new_dog = self.new
    new_dog.id, new_dog.name, new_dog.breed = dog_data[0], dog_data[1], dog_data[2]
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE dogs.id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
