class Dog
  attr_accessor :name, :breed, :id
  # attr_reader :id

  def initialize(id: nil, name:, breed: )
    @id = id
    @name = name
    @breed = breed
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
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.find_by_id(num)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL

    row = DB[:conn].execute(sql, num).first
    self.new(id: row[0], name: row[1], breed: row[2])
  end


  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?;
    SQL

    dog_from_db = DB[:conn].execute(sql, name, breed)

    if dog_from_db.empty?
      self.create(name: name, breed: breed)
    else
      dog_data = dog_from_db[0]
      self.find_by_id(dog_data[0])
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1;
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update
  end




end
