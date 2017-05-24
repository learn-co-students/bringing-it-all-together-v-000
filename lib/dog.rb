class Dog
  attr_accessor :name, :breed
  attr_reader :id
  @@all = []

  def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
      @@all << self
  end

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    if self.id
      self.update
    else
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    Dog.new(name: name, breed: breed).tap do |new_dog|
      new_dog.save
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = #{id};
    SQL
    data = DB[:conn].execute(sql)[0]
    Dog.new(id: data[0], name: data[1], breed: data[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}';
    SQL
    data = DB[:conn].execute(sql)[0]
    if !data
      self.create(name: name, breed: breed)
    else
      self.find_by_id(data[0])
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = name;
    SQL
    data = DB[:conn].execute(sql)[0]
    Dog.new(id: data[0], name: data[1], breed: data[2])
  end

end
