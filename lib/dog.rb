class Dog
  attr_accessor :name, :breed, :id

  def initialize(args = {})
    @name = args[:name]
    @breed = args[:breed]
    @id = args[:id]
  end

  def self.create_table
    table = DB[:conn].execute("SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs'")
    if table.empty?
      DB[:conn].execute('CREATE TABLE dogs ( id INTEGER PRIMARY KEY, name TEXT, breed TEXT)')
    end
  end

  def self.drop_table
    table = DB[:conn].execute("SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs'")
    if !table.empty?
      DB[:conn].execute("DROP TABLE dogs")
    end
  end

  def save
    if !self.id
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", @name, @breed)
      @id = DB[:conn].execute("SELECT id from dogs where name = ? and breed = ?", @name, @breed)[0][0]
    else
      self.update
    end
    self
  end

  def self.create(args = {})
    dog = Dog.new(args)
    dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    args = DB[:conn].execute(sql, id)
    Dog.create({:id => args[0][0], :name => args[0][1], :breed => args[0][2]})
  end

  def self.find_or_create_by(args = {})
    sql = "SELECT id, name, breed FROM dogs WHERE name = ? and breed = ?"
    dog = DB[:conn].execute(sql, args[:name], args[:breed])
    if dog.empty?
      Dog.create(args)
    else
      Dog.create({:id => dog[0][0], :name => dog[0][1], :breed => dog[0][2]})
    end
  end

  def self.new_from_db(row)
    Dog.create({:id => row[0], :name => row[1], :breed => row[2]})
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @breed, @id)
  end

end
