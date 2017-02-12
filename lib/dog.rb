class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute sql
  end

  def self.drop_table
    DB[:conn].execute "DROP TABLE dogs"
  end

  def self.create(name:, breed:)
    dog = new name: name, breed: breed
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    dog = DB[:conn].execute(sql, id).first
    new_from_db dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
    if dog
      new_from_db dog
    else
      create name: name, breed: breed
    end
  end

  def self.new_from_db(row)
    new id: row[0], name: row[1], breed: row[2]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    dog = DB[:conn].execute(sql, name).first
    new_from_db dog
  end

  def initialize(id: nil, name:, breed:)
    @id    = id
    @name  = name
    @breed = breed
  end

  def save
    if id
      update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute sql, name, breed
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute sql, name, breed, id
  end
end
