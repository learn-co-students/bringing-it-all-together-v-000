class Dog 

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id 
  end

  def update
    sql = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ? 
      WHERE id = ?
    SQL
     DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    search_sql = <<-SQL
      SELECT * FROM dogs 
      WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(search_sql, name, breed)
    if !dog.empty?
      Dog.new_from_db(dog[0])
    else
      Dog.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
  end

  def save
    # if @id
    # #   update
    # else 
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    id_sql = <<-SQL
      SELECT last_insert_rowid() FROM dogs
    SQL
    @id = DB[:conn].execute(id_sql)[0][0]
    self
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

end