class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    Dog.new(name: attributes[:name], breed: attributes[:breed]).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL

    results = DB[:conn].execute(sql, id).first
    Dog.new(id: results[0], name: results[1], breed: results[2])
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL

    results = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).first
    if results then self.find_by_id(results[0]) else self.create(attributes) end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL

    results = DB[:conn].execute(sql, name).first
    self.new_from_db(results)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL

    results = DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

end
