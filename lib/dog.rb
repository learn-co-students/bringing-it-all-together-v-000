class Dog
  attr_accessor :id , :name, :breed


  # ATTRIBUTES = {
  #   :id => "INTEGER PRIMARY KEY",
  #   :name => "TEXT",
  #   :breed => "TEXT"
  # }
  #
  # ATTRIBUTES.keys.each do |attribute_name|
  #   attr_accessor attribute_name
  # end

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
      DROP TABLE IF EXISTS dogs;
        SQL
    DB[:conn].execute(sql)
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

  def self.create(id: nil, name:, breed:)
    dog = self.new(id: id, name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE dogs.id = ?
    SQL

    dog = DB[:conn].execute(sql, id)[0]
    Dog.new(id:dog[0],name:dog[1],breed:dog[2])
  end


  def update

  end




end
