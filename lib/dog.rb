class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql= <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql) if (DB[:conn].execute("SELECT name FROM sqlite_master")).empty?
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
    sql= <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self.id
  end

  def update

  end

  def self.create(name:, breed:)
    new_dog = self.new(name:name, breed:breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql= <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    dog_data= DB[:conn].execute(sql,id)[0]
    new_dog= Dog.new(id: dog_data[0], name: dog_data[1], breed:dog_data[2])
  end

  def self.new_from_db(row)
    new_dog = self.new(id:row[0],name:row[1],breed:row[2])
    new_dog
  end

  def self.find_by_name(name)
    sql= <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    new_dog= DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name, breed)
    if new_dog.empty?
      self.create(name: name, breed: breed)
    else
      new_dog = new_dog[0]
      new_dog = Dog.new(id:new_dog[0],name:new_dog[1],breed:new_dog[2])
      new_dog
    end
  end

  def update
    sql= <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql,self.name, self.breed,self.id)
  end

end
