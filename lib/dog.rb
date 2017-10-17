class Dog
  attr_accessor :name, :breed, :id

  def initialize(params)
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?,?)
                SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
      self
    end
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
              SELECT * FROM dogs
              WHERE id = ?
              SQL
    data = {}
    data[:id] = DB[:conn].execute(sql,id)[0][0]
    data[:name] = DB[:conn].execute(sql,id)[0][1]
    data[:breed] = DB[:conn].execute(sql,id)[0][2]
    dog = self.new(data)
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    results = DB[:conn].execute(sql, name, breed)
    if !results.empty?
      data = {}
      data[:id] = DB[:conn].execute(sql,name,breed)[0][0]
      data[:name] = DB[:conn].execute(sql,name,breed)[0][1]
      data[:breed] = DB[:conn].execute(sql,name,breed)[0][2]
      dog = self.new(data)
      dog
    else
      data = {}
      data[:name] = name
      data[:breed] = breed
      dog = self.create(data)
      dog
    end
  end

  def self.new_from_db(row)
    hash = {}
    hash[:id] = row[0]
    hash[:name] = row[1]
    hash[:breed] = row[2]
    student = self.new(hash)
    student
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    results = DB[:conn].execute(sql,name)[0]
    data = {}
    data[:id] = results[0]
    data[:name] = results[1]
    data[:breed] = results[2]
    dog = self.new(data)
    dog
  end

  def update
    sql = <<-SQL
              UPDATE dogs
              SET name = ?, breed = ?
              WHERE id = ?
            SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

end
