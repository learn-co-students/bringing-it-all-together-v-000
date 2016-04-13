class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    id, name, breed = row
    self.new(name: name, breed: breed, id: id)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
      SQL
    DB[:conn].execute(sql, id).map { |row| self.new_from_db(row) }.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL
    dog_data = DB[:conn].execute(sql, name, breed) 
    if dog_data.empty?
      dog = self.create(name: name, breed: breed)
    else
      id = dog_data.first.first
      dog = self.new(name: name, breed: breed, id: id)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
      SQL
    self.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, breed, id)
  end
end