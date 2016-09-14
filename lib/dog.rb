class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    self.name = name
    self.breed = breed
    @id = id
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
      self
    else
      self
    end
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_name(name)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE name = ?', name)[0]
    self.new_from_db(row)
  end

  def self.find_by_id(id)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', id)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed)[0]
    if row != nil && row.length > 0
      self.new_from_db(row)
    else
      self.create({name: name, breed: breed})
    end
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
    DB[:conn].execute('DROP TABLE dogs')
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

end
