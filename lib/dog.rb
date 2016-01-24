class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(hash)
    @name, @breed, @id = hash[:name], hash[:breed], hash[:id]
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(attr)
    dog = Dog.new(attr)
    dog.save
    dog
  end

  def self.new_from_db(row)
    Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

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

  def self.find_or_create_by(attr)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr[:name], attr[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(dog_data)
    else
      dog = self.create(attr)
    end
    dog
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end