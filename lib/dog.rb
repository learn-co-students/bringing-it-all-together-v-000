class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def self.create_table
    sql = <<~SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id    INTEGER PRIMARY KEY,
        name  TEXT,
        breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<~SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap{|obj| obj.save}
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<~SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    dog_info = DB[:conn].execute(sql, name, breed)
    if dog_info.empty?
      self.create(name: name, breed: breed)
    else
      self.new(id: dog_info[0][0], name: dog_info[0][1], breed: dog_info[0][2])
    end
  end
  
  def self.find_by_id(id)
    sql = <<~SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL
    self.new_from_db( DB[:conn].execute(sql, id).flatten )
  end
  
  def self.find_by_name(name)
    sql = <<~SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL
    self.new_from_db( DB[:conn].execute(sql, name).first )
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2]).tap{|obj| obj.save}
  end
  
  def initialize(id: nil, name:, breed:)
    @id    = id
    @name  = name
    @breed = breed
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<~SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end
  
  def update
    sql = <<~SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end