class Dog

  attr_accessor :name, :breed, :id

  def initialize(args_hash)
    @id=args_hash[:id]
    @name = args_hash[:name]
    @breed = args_hash[:breed]
  end

  def self.create(name:, breed:)
    d = Dog.new({:name=>name, :breed=>breed})
    d.save
    d
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    d = DB[:conn].execute(sql, id).flatten
    dog = self.new({:id=>d[0], :name=>d[1], :breed=>d[2]})
  end

  def self.find_by_name(name)
    d = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    self.new_from_db(d)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    d = DB[:conn].execute(sql, name, breed)
    if !d.empty?
      dog = d[0]
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create({:name=>name, :breed=>breed})
    end
    return new_dog
  end

  def self.new_from_db(row)
    d = self.new({:id=>row[0], :name=>row[1], :breed=>row[2]})
    return d
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
end
