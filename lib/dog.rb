class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id=id
    @name=name
    @breed=breed
  end

  def self.create_table
    sql= <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql="DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
SELECT * FROM dogs WHERE id=?
SQL
    data=DB[:conn].execute(sql, id)
    if data.empty?
     sql = <<SQL
INSERT INTO dogs (name, breed) VALUES (?, ?)
SQL
    DB[:conn].execute(sql, name, breed)
    @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      update
    end

  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    attributes={}
    attributes[:id]=row[0]
    attributes[:name]=row[1]
    attributes[:breed]=row[2]
    dog = self.new(attributes)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id=?
SQL
    row=DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
SELECT * FROM dogs WHERE name=? AND breed=?
SQL
    data=DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    if data.empty?
      self.create(attributes)
    else
      row=data[0]
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
  SELECT * FROM dogs WHERE name=?
SQL
    row=DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET   name=?,
                      breed=?
                WHERE id=?
SQL
    DB[:conn].execute(sql, name, breed, id)
  end

end