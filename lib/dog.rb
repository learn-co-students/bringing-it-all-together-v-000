class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_info)
    @name = dog_info[:name]
    @breed = dog_info[:breed]
    dog_info[:id] ||= nil
    @id = dog_info[:id]
    # ???
  end

  def self.create_table
    sql =<<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =<<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql =<<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.create(dog_info)
    dog = Dog.new(dog_info)
    dog.save
  end

  def self.find_by_id(id)
    sql =<<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog_from_db = DB[:conn].execute(sql, id)[0]
    self.new_from_db(dog_from_db)
  end

  def self.find_or_create_by(dog)
    name = dog[:name]
    breed = dog[:breed]
    sql =<<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dogs = DB[:conn].execute(sql, name, breed)
    if !dogs.empty?
      dog[:id] = dogs[0][0]
      Dog.new(dog)
    else
      self.create(dog)
    end
  end

  def self.new_from_db(row)
    dog_hash = {}
    dog_hash[:id] = row[0]
    dog_hash[:name] = row[1]
    dog_hash[:breed] = row[2]
    Dog.new(dog_hash)
  end

  def self.find_by_name(name)
    sql =<<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    dog_from_db = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog_from_db)
  end

  def update
    sql =<<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
