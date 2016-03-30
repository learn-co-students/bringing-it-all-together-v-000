class Dog
  attr_accessor :name
  attr_reader :breed, :id

  def initialize(attributes)
    self.name = attributes[:name]
    @breed = attributes[:breed]
    @id = attributes[:id]
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
  end

  def update
    unless self.id
      self.save
    else
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL

    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.find_or_create_by(attributes)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", attributes[:name], attributes[:breed])
    if !dog.empty?
      dog = self.new_from_db(dog[0])
    else
      dog = self.create(attributes)
    end
  end
end