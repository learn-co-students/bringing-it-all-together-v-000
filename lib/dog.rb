class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    dog = self.create(name: row[1], breed: row[2])
    dog.id = row[0]
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    found = DB[:conn].execute(sql, id)
    dog = self.new_from_db(found[0])
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    found = DB[:conn].execute(sql, name)
    dog = self.new_from_db(found[0])
    puts dog.name
    dog
  end

  def self.find_or_create_by(name:, breed:)
    info = DB[:conn].execute("SELECT * FROM dogs WHERE (name = ? AND breed = ?)", name, breed)
    if !info.empty?
      info_data = info[0]
      dog = self.find_by_id(info_data[0])
      #dog = self.new(name: info_data[1], breed: info_data[2], id: info_data[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end
