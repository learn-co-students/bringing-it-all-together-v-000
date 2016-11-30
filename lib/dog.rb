class Dog

  attr_accessor :name, :breed, :id

  def initialize(args)
    @name = args[:name]
    @breed = args[:breed]
    @id = args[:id] || nil
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
    DB[:conn].execute('DROP TABLE dogs')
  end

  def save
    sql = 'INSERT INTO dogs (name, breed) VALUES (?,?)'
    DB[:conn].execute(sql,@name,@breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0][0]
    self
  end

  def self.create(args)
    new_dog = self.new(args)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ?'
    row = DB[:conn].execute(sql,id)[0]
    found_dog = self.new(id: row[0], name: row[1], breed: row[2])
    found_dog
  end

  def self.find_or_create_by(args)
    sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?'
    row = DB[:conn].execute(sql,args[:name],args[:breed])[0]
    if row == nil
      self.create(args)
    else
      self.find_by_id(row[0])
    end
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_by_name(name)
    sql = 'SELECT * FROM dogs WHERE name = ?'
    row = DB[:conn].execute(sql,name)[0]
    self.new_from_db(row)
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql,@name,@breed,@id)
  end


end