class Dog
  attr_accessor :name, :breed, :id
  #attr_reader :id

  #def initialize(:id=nil,:name,:breed)
  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed INT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
      DROP TABLE dogs
        SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    Dog.new({:name => row[1],:breed => row[2],:id => row[0]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
      SQL
      DB[:conn].execute(sql,name).map {|r|
        self.new_from_db(r)
      }.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      #duplicate?
      #sql = <<-SQL
        #SELECT  dogs (name, breed)
        #VALUES (?, ?)
        #SQL
      #DB[:conn].execute(sql, self.name, self.breed)

      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(attributes)
    Dog.new(attributes).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      SQL
      DB[:conn].execute(sql,id).map {|r|
        self.new_from_db(r)
      }.first
  end

  def self.find_or_create_by(attributes)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
    if !dog.empty?
      Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
    else
      self.create(attributes)
    end
  end

end
