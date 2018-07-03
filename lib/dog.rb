class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id = nil, name, breed)
    @id = id
    @name = name
    @breed = breed
  end

end
