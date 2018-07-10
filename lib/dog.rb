class Dog

  attr_accessor :id, :name, :breed

  def initialize(name: , breed: , id:nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =<<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def self.create(name: name, breed: breed)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def save
    if self.id
      self.update
    else
      sql =<<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
      self
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    self.new_from_db(dog_data)
  end

  def self.find_by_name(name)
    dog_data = DB[:conn].execute('SELECT * FROM dogs WHERE name = ?', name)[0]
    self.new_from_db(dog_data)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name: name, breed: breed)
    dog_data = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed)
    if !dog_data.empty?
      new_dog = self.new_from_db(dog_data[0])
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

end
