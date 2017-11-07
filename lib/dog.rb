
class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self #Here to return an instance of the dog class
  end

  def self.create(data)
    new_dog = self.new(data)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id_num)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id_num)[0]

    self.new_from_db(row)
  end

  def self.new_from_db(row)
    id, name, breed = row[0], row[1], row[2]
    new_dog = self.new(id: id, name: name, breed: breed)
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty? # You can't put [0] at the end of the previous line b/c if you get a nil result,
        # dog will = nil and !dog.empty? will make no sense to the interpreter. You need the prior line to
        # return a nested array of some kind.  Think about it.
      dog_data = dog[0]
      self.new_from_db(dog_data)
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0]
    self.new_from_db(row)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end # Class end
