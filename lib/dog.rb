class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id=nil, args)
    @id = id
    @name = args[:name] if args[:name]
    @breed = args[:breed] if args[:breed]
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
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(args)
    Dog.new(args).save
  end

  def self.find_by_id(id)
      dog_details = DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1", id[0])
      Dog.new(id, {name: dog_details[1], breed: dog_details[2]})
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(dog_data[0], {name: dog_data[1], breed: dog_data[2]})
    else
      dog = self.create({name: name, breed: breed})
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(row[0], {name: row[1], breed: row[2]})
  end 

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    Dog.new(dog[0], {name: dog[1], breed: dog[2]})
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end
end