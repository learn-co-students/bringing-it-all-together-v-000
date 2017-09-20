class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_hash)


    @id = dog_hash[:id]
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]


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
  def save

      sql = <<-SQL
        INSERT INTO dogs ( name, breed)
        VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
  end
  def self.create(dog_hash)

    new_dog = self.new(dog_hash)
    new_dog.save
    #binding.pry

  end

  def self.new_from_db(row)
    new_hash = {}
    new_hash = {:id => row[0], :name => row[1], :breed => row[2] }

    new_dog = self.new(new_hash) unless row.empty?


  end

  def self.find_by_id(num)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, num).map do |row|
         self.new_from_db(row)

    end.first
    #binding.pry




  end
  def self.find_by_name(nam)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, nam).map do |row|
         self.new_from_db(row)

    end.first
    #binding.pry




  end
  def self.find_or_create_by(hashes)

    names = hashes[:name]
    breeds = hashes[:breed]
    match = self.find_by_name(names)
    #binding.pry
    if match.breed == breeds

      self.find_by_name(names)
    else

      self.create(hashes)

    end

  end



  def update
   sql = <<-SQL
   UPDATE dogs
   SET name = ?, breed = ?
   WHERE ?
   SQL

   DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

end
