class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
  end

  def self.create_table
    sql=<<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql=<<-SQL
    DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end
  def self.create(name,grade)
    dog = Dog.new(name,grade)
    dog.save
  end
  def save
    if self.id
      self.update
    else
      sql=<<-SQL
      INSERT INTO dogs (name,breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end
  def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed, self.id)
 end
  def self.find_by_id(id)
    sql=<<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql,id)[0]
    self.new(row[0],row[1],row[2])
  end
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id,name,breed)
  end
  def self.find_by_name(name)
  # find the student in the database given a name
  # return a new instance of the Student class
  sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? LIMIT 1
  SQL

  DB[:conn].execute(sql,name).map do |row|
    self.new_from_db(row)
  end.first
end
end
