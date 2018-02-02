class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id = nil, hash)
    @id = id
    @name = hash[:name]
    @breed = hash[:breed]
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
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
      SQL

      result = DB[:conn].execute(sql, id)[0]

      new_from_db(result)
  end

  def self.find_or_create_by
    # not given any parameters, so what can I use to find it?
  end

  def self.new_from_db(row)
    hash = {:id => row[0],
      :name => row[1],
      :breed => row[2]
    }

    self.new(hash[:id], hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name)[0]

    new_from_db(result)
  end

  def update
    sql = "UPDATE dogs SET name = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.id)
  end

end
