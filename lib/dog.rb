class Dog
    attr_accessor :name, :breed, :id



  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
   sql = <<-SQL
   CREATE TABLE IF NOT EXISTS dogs (
     id INTEGER PRIMARY KEY, name TEXT, breed TEXT
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

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

   def self.create(row)
    new_dog = Dog.new(row)
    new_dog.save
    new_dog
   end

   def self.find_by_id(id)
     sql = <<-SQL
     SELECT * FROM dogs
     WHERE id = ?
     SQL
dog = DB[:conn].execute(sql, id)[0]
  dog = Dog.new(name: dog[1], breed: dog[2], id: dog[0])
  dog
    end
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
if !dog.empty?
  dog_d = dog[0]
  dog = Dog.new(id: dog_d[0], name: dog_d[1], breed: dog_d[2])
else
  dog = self.create(name: name, breed: breed)
end
dog
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
 end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL

    name = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
   end.first
 end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
