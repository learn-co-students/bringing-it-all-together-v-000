class Dog
  attr_accessor :name
  attr_reader :breed, :id
  def initialize(name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
  end

  def self.new_from_db(row)
    self.new(id:row[0], name:row[1], breed:row[2])
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
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
      sql = <<-SQL
        INSERT INTO dogs (name,breed)
        VALUES (?,?)
      SQL
      var = DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1;").flatten[0]
      self
  end

  def self.create(name:, breed:)
    self.new(name:name, breed:breed).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    dog=DB[:conn].execute(sql,id).flatten
    new_from_db(dog)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    dog = DB[:conn].execute(sql,name).flatten
    new_from_db(dog)
  end

  def self.find_or_create_by(name:,breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    if dog.empty?
      new_dog = create(name:name, breed:breed)
    else
      new_dog = new(id:dog[0][0], name:dog[0][1], breed:dog[0][2])
    end
  end

  def update
    sql= <<-SQL
      UPDATE dogs
      SET name = ?, breed =?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
