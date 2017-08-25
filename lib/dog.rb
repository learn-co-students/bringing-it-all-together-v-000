require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

  COLUMNS_NAME = {id: "INTEGER PRIMARY KEY", name: "TEXT", breed: "TEXT"}

  def self.columns_name_for_table
    COLUMNS_NAME.collect{|k,v|"#{k} #{v}"}.join(",")
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self}s
      (#{self.columns_name_for_table} )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS #{self}s")
  end

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def save
    DB[:conn].execute("SELECT * FROM dogs").empty?
  end

end
