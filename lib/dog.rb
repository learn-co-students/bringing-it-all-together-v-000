class Dog

  attr_accessor :name, :breed, :id



  def initialize(id=nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)

  end

  def self.new_from_db(row)
    h = {name: row[1], breed: row[2] }
    new_dog = self.create(h)
    new_dog.id = row[0]
    new_dog
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES(?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(h)
    new_dog = self.new(h)
    new_dog.save
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    hresult = {name: result[1], breed: result[2]}
    new_dog = self.create(hresult)
    new_dog.id = result[0]
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      new_dog = self.find_by_id(dog[0][0])
    else
      h = {name: name, breed: breed}
      new_dog = self.create(h)
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    hresult = {name: result[1], breed: result[2]}
    new_dog = self.create(hresult)
    new_dog.id = result[0]
    new_dog
  end













end
