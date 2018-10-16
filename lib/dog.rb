class Dog
  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(record)
    new(id: record[0], name: record[1], breed: record[2])
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map { |record| new_from_db(record) }[0]
  end

  def self.find_by_id(id)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).map { |record| new_from_db(record) }[0]
  end

  def save
    if id
      update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    new(name: name, breed: breed).save
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      record = dog[0]
      new(id: record[0], name: record[1], breed: record[2])
    else
      create(name: name, breed: breed)
    end
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name, breed, id)
  end
end
