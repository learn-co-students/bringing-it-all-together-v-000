class Dog

  attr_accessor :name, :breed, :id

  def initialize(name,breed,id=nil)
    @name = name
    @breed = breed
    @id = id
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
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    #
      sql = <<-SQL
        INSERT INTO dogs (name,breed)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    #end
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name,breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE id = ?
    SQL

    result = DB[:conn].execute(sql,id)[0]

    Dog.new(result[1],result[2],result[0])
  end

  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name,breed)

    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(dog_data[1],dog_data[2],dog_data[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    new_dog = Dog.new(row[1],row[2])
    new_dog.id = row[0]
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end