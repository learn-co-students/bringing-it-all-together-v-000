class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize (name:, breed:, id: nil)
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    !self.id ? insert : update
  end

  def insert
    sql = <<-SQL
    INSERT INTO dogs(name, breed) VALUES(?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed =? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    Dog.new(hash).tap{|x| x.save}
  end

  def self.new_from_db(row)
    Dog.new(name:row[1], breed:row[2], id:row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    !dog.empty? ? dog = self.new_from_db(dog[0]) : dog = self.create(name: name, breed: breed)
  end
end
