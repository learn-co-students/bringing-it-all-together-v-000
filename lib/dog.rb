class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    self.name = name
    self.id = id
    self.breed = breed
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
    DB[:conn].execute('DROP TABLE dogs')
  end

  def self.new_from_db(row)
    id, name, breed = row
    new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.create(hash)
    dog = new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(hash)
    dog = self.find_by_name(hash[:name])

    dog ? dog : create(hash)
  end

  def save
    if self.id
      self.update
      return self
    end

    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end
end
