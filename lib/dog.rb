class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @breed = breed
    @name = name
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(record)
    self.new(id: record[0], name: record[1], breed: record[2])
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap { |dog| dog.save }
  end

  def self.find_by_id(id_of_record)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    record = DB[:conn].execute(sql, id_of_record).first
    self.new_from_db(record)
  end

  def self.find_by_name(name_of_record)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    record = DB[:conn].execute(sql, name_of_record).first
    self.new_from_db(record)
  end

  def self.find_or_create_by(name:, breed:)
    record = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !record.empty?
      self.new_from_db(record.first)
    else
      self.create(name: name, breed: breed)
    end
  end

end
