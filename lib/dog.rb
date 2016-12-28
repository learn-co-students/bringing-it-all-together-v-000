class Dog

  attr_accessor :name
  attr_reader   :breed, :id
  
  def initialize(name:, breed:, id:nil)
    @name  = name
    @breed = breed
    @id    = id
  end

  def self.create(name:, breed:)
    dog = self.new(name:name, breed:breed)
    dog.save
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id      INTEGER PRIMARY KEY,
        name    TEXT,
        breed   TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    rows = DB[:conn].execute(sql, id)
    new_from_db(rows[0]) if rows.size > 0
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    rows = DB[:conn].execute(sql, name)
    new_from_db(rows[0]) if rows.size > 0
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    rows = DB[:conn].execute(sql, name, breed)
    if rows.size > 0
      new_from_db(rows[0])
    else
      create(name:name, breed:breed)
    end
  end
  
  def self.new_from_db(row)
    self.new(name:row[1], breed:row[2], id:row[0])
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @breed, @id)
  end
end
