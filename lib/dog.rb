class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end
  def self.create_table
    create = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(create)
  end
  def self.drop_table
    drop = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(drop)
  end
  def save
    if self.id
      self.update
    else
      save = <<-SQL
        INSERT INTO dogs(name, breed) VALUES(?, ?)
      SQL
      DB[:conn].execute(save, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end
  def self.find_by_id(id)
    find = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(find, id)[0])
  end
  def self.find_or_create_by(name:, breed:)
    find = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL
    found = DB[:conn].execute(find, name, breed)[0]
    if found.nil? || found.empty?
      dog = self.create(name: name, breed: breed)
    else
      dog = Dog.new(id: found[0], name: found[1], breed: found[2])
    end
    dog
  end
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  def self.find_by_name(name)
    find = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(find, name)[0])
  end
  def update
    update = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(update, self.name, self.breed, self.id)
  end
end