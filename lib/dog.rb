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
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs;"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed= ? where id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



  def save

    if self.id
      self.update
    else
      sql = "INSERT INTO dogs(name, breed) VALUES(?, ?);"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    self.new(name:name, breed:breed).save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name:row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    found_row = DB[:conn].execute(sql, id).first

    self.new_from_db(found_row)
  end

  def self.find_by_name(name)
    found_dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    if !found_dogs.empty?
      found_dogs.map! do |dog|
        self.new_from_db(dog)
      end
    end
    found_dogs.first
  end



  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)

    if !dog.empty?
      dog_data = dog.first
      dog = self.new_from_db(dog_data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end



end
