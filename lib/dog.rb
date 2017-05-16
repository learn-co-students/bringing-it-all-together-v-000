class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create(hash_attr)
    self.new(hash_attr).save
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT* FROM dogs
      WHERE id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = #{self.id}
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.find_by_name_and_breed(name, breed)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL
    self.new_from_db(DB[:conn].execute(sql, name, breed).flatten)
  end

  def self.find_or_create_by(hash_attr)
    result = self.find_by_name_and_breed(hash_attr[:name], hash_attr[:breed])
    if result.id.nil?
      result.tap { |r| r.name = hash_attr[:name]; r.breed = hash_attr[:breed] }.save
    end

    result
  end
end
