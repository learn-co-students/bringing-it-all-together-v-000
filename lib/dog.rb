class Dog
  attr_accessor  :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    rows = DB[:conn].execute(sql, name, breed)
    if rows.empty?
      self.create(name: name, breed: breed)
    else
      self.new_from_db(rows[0])
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    rows = DB[:conn].execute(sql, name)
    self.new_from_db(rows[0])
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    self.id.nil? ? insert : update
    self
  end

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES
      (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    rows = DB[:conn].execute(sql, id)
    new_from_db(rows[0])
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end
end
