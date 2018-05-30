class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil )
    @name = name
    @breed = breed
    @id = id
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end


  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    # @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self

    # binding.pry
    # @id =
  end


  def self.create(name:, breed:, id: nil)
    # binding.pry
    new_dog = Dog.new(name: name, breed: breed, id: nil)
    new_dog.save
    new_dog
    # binding.pry
    #
    # new_dog.name = attributes_hash[:name]
    # new_dog.breed = attributes_hash[:breed]
    # new_dog.save
    # binding.pry
  end


  def self.find_by_id(id_given)

    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    # binding.pry
    found_dog = DB[:conn].execute(sql, id_given)[0]
    Dog.new(name: found_dog[1], breed: found_dog[2], id: found_dog[0])

    # self.create(name: found_dog[1], breed: found_dog[2], id: found_dog[0])
    # binding.pry
  end


  def self.find_or_create_by(name:, breed:)
    dog =  DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(name: dog_data[1], breed:dog_data[2], id:dog_data[0])
    else
      dog = self.create(name: name, breed: breed, id: nil)
    end
    dog
  end

  def self.new_from_db(row)
    # binding.pry
    new_dog = self.find_or_create_by(name:row[1], breed:row[2])
    new_dog
  end

  def self.find_by_name(name)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ?
        SQL
        # binding.pry
        found_dog = DB[:conn].execute(sql, name)[0]
        Dog.new(name: found_dog[1], breed: found_dog[2], id: found_dog[0])
  end


  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end
