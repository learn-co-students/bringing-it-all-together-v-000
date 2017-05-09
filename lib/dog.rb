class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.new_from_db(dog_row)
    self.new(name: dog_row[1], breed: dog_row[2], id: dog_row[0])
  end

  def self.create_table
    DB[:conn].execute(<<-SQL)
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
  end

  def self.drop_table
    DB[:conn].execute(<<-SQL)
      DROP TABLE IF EXISTS dogs;
    SQL
  end

  # #save inserts current instance in db or updates if it already exists
  def save
    if self.id
      self.update
    else
      DB[:conn].execute(<<-SQL, self.name, self.breed)
        INSERT INTO dogs (name, breed)
        VALUES (?, ?);
      SQL
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end

  # .create makes a new instance of dog from row information and saves to DB.
  def self.create(dog_hash)
    self.new(dog_hash).tap {|dog| dog.save}
  end

  # .find_by_id finds row by id and then intantiates a new Dog object
  def self.find_by_id(id)
    dog_row = DB[:conn].execute(<<-SQL, id).first
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL
    self.new_from_db(dog_row)
  end

  def self.find_or_create_by(name:, breed:)
    dog_row = DB[:conn].execute(<<-SQL, name, breed)
      SELECT *
      FROM dogs
      WHERE dogs.name = ? AND dogs.breed = ?;
    SQL

    dog_row.empty? ? self.create(name: name, breed: breed) : self.new_from_db(dog_row.first)
  end

  def self.find_by_name(name)
    dog_row = DB[:conn].execute(<<-SQL, name).first
      SELECT *
      FROM dogs
      WHERE name = ?;
    SQL
    self.new_from_db(dog_row)
  end

  def update
    DB[:conn].execute(<<-SQL, self.name, self.breed, self.id)
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL
  end

end
