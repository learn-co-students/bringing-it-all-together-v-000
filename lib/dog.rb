class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.table_name} (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS #{self.table_name}"

    DB[:conn].execute(sql)
  end

  def self.create(hash)
    new_dog = self.new(name: hash[:name], breed: hash[:breed])
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM #{self.table_name} WHERE id = ?"

    row = DB[:conn].execute(sql, id).flatten
    self.reify_from_row(row)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      row = dog[0]
      dog = self.reify_from_row(row)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    self.reify_from_row(row)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"

    row = DB[:conn].execute(sql, name)[0]
    self.reify_from_row(row)
  end

  def self.reify_from_row(row)
     self.new(id: row[0], name: row[1], breed: row[2])
  end

  def save
    persisted? ? update : insert
    self
  end

  def persisted?
    !!self.id
  end

  def insert
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (name, breed)
      VALUES (?, ?)
      SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() from #{self.class.table_name}").flatten.first
  end

  def update
    sql = <<-SQL
      UPDATE #{self.class.table_name} SET name = ?, breed = ? WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
      self
  end
end
