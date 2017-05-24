class Dog
  attr_accessor :name,:breed
  attr_reader :id

  def initialize(name:,breed:,id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
    SQL
    row = DB[:conn].execute(sql,id).first
    self.new_from_db(row)
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name:row[1],breed:row[2],id:row[0])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name=? AND breed=?;
    SQL

    matches = DB[:conn].execute(sql,hash[:name],hash[:breed])

    if !matches.empty?
      self.new_from_db(matches.first)
    else
      self.create(name:hash[:name],breed:hash[:breed])
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name=?;
    SQL

    self.new_from_db(DB[:conn].execute(sql,name).first)
  end


  ##INSTANCE METHODS##

  def save
    sql = <<-SQL
      INSERT INTO dogs(name,breed) VALUES (?,?);
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name=?,breed=? WHERE id=?;
    SQL

    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end
end
