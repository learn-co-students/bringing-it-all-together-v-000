# Dog class
class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.new_from_db(row)
    dog = self.create(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed)
    if dog.empty?
      dog = self.create(name: name, breed: breed)
    else
      dog_info = dog.first
      dog = self.create(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    end
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      create(id: row[0], name: row[1], breed: row[2])
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      create(id: row[0], name: row[1], breed: row[2])
    end.first
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
    sql = 'DROP TABLE IF EXISTS dogs'
    DB[:conn].execute(sql)
  end

  def save
    if self.id.nil?
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    else
      self.update
    end
    self
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql, name, breed, id)
  end
end
