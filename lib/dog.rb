class Dog
  attr_accessor :name, :breed, :id
  # attr_reader :id

  def initialize(param_hash)
    param_hash.each do |attr, value|
      self.send("#{attr}=", value)
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(param_hash)
    self.new(param_hash).save
  end

  def self.find_by_id(num)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL

    attr_array = DB[:conn].execute(sql, num).first
    # converting row (attr_array) to a hash usable for inialization
    attr_hash = {id: attr_array[0], name: attr_array[1], breed: attr_array[2]}
    self.new(attr_hash)
  end

  # def find_or_create_by(attr_hash)
  #   sql
  # end



end
