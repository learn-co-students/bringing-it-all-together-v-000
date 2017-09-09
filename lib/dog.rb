class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each {|attr, value| self.send("#{attr}=", value)}
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(dog_info)
    dog_attributes = {id: dog_info[0], name: dog_info[1], breed: dog_info[2]}
    dog = Dog.new(dog_attributes)
    dog
  end

  def save
    save_dog_sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
    select_dog_id_sql = "SELECT id FROM dogs WHERE name = ? AND breed = ?;"

    DB[:conn].execute(save_dog_sql, self.name, self.breed)
    @id = DB[:conn].execute(select_dog_id_sql, self.name, self.breed).flatten[0]
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    dog_found = DB[:conn].execute(sql, id).flatten

    new_from_db(dog_found)
  end

  def self.find_or_create_by(attributes)
    name = attributes[:name]
    breed = attributes[:breed]

    find_dog_sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog_found = DB[:conn].execute(find_dog_sql, name, breed)

    # If database search returns empty array, create a new dog in the database using the attributes hash
    # else get first array from the results (dog was found) and make a new instance of dog to return
    if dog_found.empty?
      self.create(attributes)
    else
      self.new_from_db(dog_found[0])  
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    dog_info = DB[:conn].execute(sql, name)[0]

    self.new_from_db(dog_info)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end