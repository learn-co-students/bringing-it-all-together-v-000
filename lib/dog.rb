class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs
    ( id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL

      row = DB[:conn].execute(sql, self.name, self.breed)[0]
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(name: name, breed: breed)
    dog = self.new(name, breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id=(?)
    SQL

    row = DB[:conn].execute(sql, id)[0]
    dog_instance = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name, breed)
    sql = <<-SQL
    SELECT * FROM dogs (name, breed)
    WHERE name=(?), breed=(?)
    SQL

    query = DB[:conn].execute(sql, name, breed)[0]

    if query.empty?
      dog = self.new(name: name, breed: breed)
      dog.save
    else
      dog = self.new(id: query[0], name: query[1], breed: query[2])
      dog
    end
  end

end
