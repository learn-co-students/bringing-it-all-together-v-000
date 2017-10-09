class Dog
attr_accessor :name, :breed
attr_reader :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name, TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    Dog.new(name:name, breed:breed).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end

  def self.new_from_db(row)
     Dog.new(id:row[0],name:row[1], breed:row[2])
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
      @id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ?", self.name)[0].first
      self
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    if !self.find_by_name(name)
      self.create(name, breed)
    else
      row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
      self.new_from_db(row)
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end  #  End of Class
