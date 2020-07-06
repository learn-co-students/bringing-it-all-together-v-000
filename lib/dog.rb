class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
  end


end
