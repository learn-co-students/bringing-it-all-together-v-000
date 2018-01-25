class Dog
  attr_accessor :name, :breed
  attr_reader :id

  #///CLASS MEHTODS///#
  def initialize(args)
    @id = args[:id] if args[:id]
    @name = args[:name] if args[:name]
    @breed = args[:breed] if args[:breed]
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(dog)
    dog_hash = {:id => dog[0], :name => dog[1], :breed => dog[2]}
    self.new(dog_hash)
  end

  def self.create(args)
    dog = self.new(args)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    self.new_from_db(DB[:conn].execute(sql,id)[0])
  end

  def self.find_or_create_by(args)
    sql = "SELECT id FROM dogs WHERE name = ? AND breed = ?"
    id = DB[:conn].execute(sql, args[:name], args[:breed])
    id != [] ? self.find_by_id(id[0][0]) :  self.create(args)
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end

  #///INSTANCE METHODS///#

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name,breed) VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql,self.name, self.breed, self.id)
    self
  end



end