class Dog
  attr_accessor :id, :name, :breed

  def initialize (id: nil, name:, breed:)
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
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create (name:, breed:)
    new_dog = Dog.new(name: name, breed: breed).tap {|dog| dog.save}
  end

  def self.new_from_db(row) #row will be an Array [id, name, breed]
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql,id).first)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql,name).first)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

    if !dog.empty? #if found in DB (returns something/not empty)
      dog_instance = dog[0]
      dog = Dog.new(id: dog_instance[0], name: dog_instance[1], breed: dog_instance[2])
    else #if not found, create and save an new dog instance
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def update #instance method
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ?
    WHERE id = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql,self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
      self
    end
  end


end
