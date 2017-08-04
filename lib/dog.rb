class Dog
  attr_accessor :id, :name, :breed

  def initialize(obj)
    @name = obj[:name]
    @breed = obj[:breed]
    @id = obj[:id]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        bree TEXT
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

  def save
    if @id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, @name, @breed)

      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def self.create(obj)
    x = self.new(obj)
    x.save
    x
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
    self
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql,id)[0])
  end

  def self.new_from_db(row)
    self.new(name:row[1], breed:row[2], id:row[0])
  end

  def self.find_or_create_by(obj)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    data = DB[:conn].execute(sql, obj[:name],obj[:breed])
    if !data.empty?
      x = self.new(name:data[0][1],breed:data[0][2],id:data[0][0])
    else
      x = self.create(obj)
    end
    x
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end
end
