require 'nearby/point'

class Nearby::Space
  attr_accessor :distance_func, :root

  def initialize(distance_func)
    @distance_func = distance_func
    @root = nil
  end

  def insert(*objects)
    objects.each do |object|
      new_point = Nearby::Point.new(object, @distance_func)

      if @root.nil?
        @root = new_point
      else
        @root.insert(new_point)
      end
    end
  end

  def to_s
    space_str = @root.nil? ? "nil" : @root
    "Space: #{space_str}"
  end
end
