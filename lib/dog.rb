class Dog
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :breed => "TEXT"
  }

  ATTRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create(hash)
    new_dog = self.new(name: hash[:name], breed: hash[:breed])
    new_dog.save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.create_sql
    ATTRIBUTES.collect{|attribute_name, schema| "#{attribute_name} #{schema}"}.join(",")
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.table_name} (
        #{self.create_sql}
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS #{self.table_name}"

    DB[:conn].execute(sql)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM #{self.table_name} WHERE id = ?"

    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      row = dog[0]
      dog = self.new_from_db(row)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def save
    persisted? ? update : insert
    self
  end

  def persisted?
    !!self.id
  end

  def self.attribute_names_for_insert
    ATTRIBUTES.keys[1..-1].join(",")
  end

  def self.question_marks_for_insert
    (ATTRIBUTES.keys.size-1).times.collect{"?"}.join(",")
  end

  def attribute_values
    ATTRIBUTES.keys[1..-1].collect{|attribute_name| self.send(attribute_name)}
  end

  def self.sql_for_update
    ATTRIBUTES.keys[1..-1].collect{|attribute_name| "#{attribute_name} = ?"}.join(",")
  end

  def insert
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (#{self.class.attribute_names_for_insert})
      VALUES (#{self.class.question_marks_for_insert})
      SQL

    DB[:conn].execute(sql, *attribute_values)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() from #{self.class.table_name}").flatten.first
  end

  def update
    sql = <<-SQL
      UPDATE #{self.class.table_name} SET #{self.class.sql_for_update} WHERE id = ?
      SQL

      DB[:conn].execute(sql, *attribute_values, self.id)
      self
  end
end
