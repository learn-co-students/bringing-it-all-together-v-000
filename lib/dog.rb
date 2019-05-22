class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash, id = nil)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?, ?)
    SQL
    row = DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    self.new({:name => row[1], :breed => row[2]}, row[0])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
    if row.is_a? Array
      dog = self.new({:name => row[1], :breed => row[2]}, row[0])
    else
      dog = self.create(hash)
    end
    dog
  end

  def self.new_from_db(row)
    self.new({:name => row[1], :breed => row [2]}, row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
