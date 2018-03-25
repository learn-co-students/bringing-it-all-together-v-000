class Dog

  attr_accessor :id, :name, :breed

  def initialize(params)
    params.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      self.insert
    end
    self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE if NOT EXIST dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE if EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(row)
    dog = self.new(row)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]

    dog = self.new_from_db(row)
  end

  def self.new_from_db(row)
    attributes = {id: row[0], name: row[1], breed: row[2]}
    dog = self.new(attributes)
    #binding.pry
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]

    dog = self.new_from_db(row)
  end

  def self.find_or_create_by(params)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, params[:name], params[:breed])[0]

    if !row.nil?
      dog = self.new_from_db(row)
      #binding.pry
    else
      dog = self.create(params)
    end
    dog
  end

end
