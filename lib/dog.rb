class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(attributes)
    if attributes
      attributes.each do |k,v|
        self.send("#{k}=", v)
      end
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed, TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL 
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES(?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self.new_from_db(rows)
  attributes = self.new({id: rows[0], name: rows[1], breed: rows[2]})
  attributes
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
      DB[:conn].execute(sql, id).map do |rows|
        self.new_from_db(rows)
      end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
     self.find_by_id(dog[0][0])
    else
      dog = self.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
      DB[:conn].execute(sql, name).map do |rows|
        self.new_from_db(rows)
  end.first
end

def update
  sql = <<-SQL
  UPDATE dogs SET name = ?, breed = ? WHERE id = ?
  SQL
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

end