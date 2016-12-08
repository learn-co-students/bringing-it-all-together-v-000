class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<~SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name).first
    new_from_db(row)
  end

  def self.find_by_id(id)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL

    row = DB[:conn].execute(sql, id).first
    new_from_db(row)
  end

  def self.create(name:, breed:, id: nil)
    self.new(name: name, breed: breed, id: id).save
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    matches = DB[:conn].execute(sql, name, breed)
    if matches.empty?
      self.create(name: name, breed: breed)
    else
      new_from_db(matches.first).save
    end
  end

  def update
    sql = <<~SQL
      UPDATE dogs
        SET name = ?, breed = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def save
    sql = <<~SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL

    if self.id
      update
    else
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      self
    end
  end

end
