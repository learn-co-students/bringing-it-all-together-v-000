require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    attributes.each{|k, v| send("#{k}=", v)}
  end



  def self.create_table
    DB[:conn].execute(
      "CREATE TABLE IF NOT EXISTS
      dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    )
  end

  def self.drop_table
    DB[:conn].execute(
      "DROP TABLE IF EXISTS dogs;"
    )
  end

  def self.create(attributes)
    Dog.new(attributes).tap{|s| s.save}
  end

  def self.new_from_db(row)
    Dog.new({name: row[1], breed: row[2], id: row[0]})
  end

  def self.find_by_name(name)
    self.new_from_db(
      DB[:conn].execute("SELECT * FROM dogs
      WHERE name = (?);", name).flatten
      )
  end

  def self.find_by_id(id)
    self.new_from_db(
      DB[:conn].execute("SELECT * FROM dogs
      WHERE id = (?);", id).flatten
      )
  end

  def self.find_or_create_by(attributes)
    self.create(attributes)
  end




  def save
    if already_exists?
      update
    else
      DB[:conn].execute(
        "INSERT INTO dogs (name, breed)
        VALUES (?,?);",
        self.name, self.breed
      )

      @id = DB[:conn].execute(
        "SELECT last_insert_rowid()
        FROM dogs;"
      )[0][0]
    end

    self

  end

  def update
    if self.id
      DB[:conn].execute(
        "UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?;",
        self.name, self.breed, self.id
      )
    else
      self.id = DB[:conn].execute(
        "SELECT id FROM dogs
        WHERE name = ? AND breed = ?;",
        self.name, self.breed
      )[0][0]
    end


  end

  def already_exists?
    if self.id

      true

    elsif DB[:conn].execute("SELECT * FROM dogs
      WHERE name = ? AND breed = ?;",
      self.name, self.breed).size == 1

      true

    else

      false

    end
  end

end