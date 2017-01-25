class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def initialize(attributes)
    @id = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]
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

  def self.new_from_db(row)
    dog = Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    new_from_db(DB[:conn].execute(sql, name).first)
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ?
    WHERE id = ?;
    SQL
    DB[:conn].execute(sql, name, breed, id)
  end

  def self.create(attributes)
    Dog.new(attributes).save
  end

  def self.find_or_create_by(name:, breed:)
    if DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed).empty?
      create({name: name, breed: breed})
    else
      new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed).first)
    end
  end

  def save
    if id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end
end