
class Dog
  attr_accessor :name, :breed, :id
  #attr_reader :id

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create(args)
    dog = Dog.new(args)
    dog.save
    dog
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(db)
    attributes = {:id => db[0], :name => db[1], :breed => db[2]}
    Dog.create(attributes)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs 
    WHERE id = ?
    SQL

    dog = Dog.new_from_db(DB[:conn].execute(sql, id)[0])
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * 
      FROM dogs 
      WHERE name = ? 
      LIMIT 1
      SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(args)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", args[:name], args[:breed])

    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(args)
    end
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = 1"
    DB[:conn].execute(sql, self.name, self.breed)
  end

  def save
    if self.id 
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
 
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

end