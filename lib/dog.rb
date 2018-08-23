class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize (id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql= "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed)
      VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

 def self.create(row)
   dog = self.new(row)
   dog.save
   dog
 end

 def self.find_by_id(id)
   sql = "SELECT * FROM dogs WHERE id = ?"
   result = DB[:conn].execute(sql, id)[0]
   self.new_from_db(result)
 end

 def self.find_or_create_by(name:name, breed:breed)
   dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
   if !dog.empty?
     dog = self.new_from_db(dog[0])
   else
     dog = self.create(name:name, breed:breed)
   end
   dog
 end

end
