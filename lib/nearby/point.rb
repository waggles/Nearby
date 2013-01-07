class Nearby::Point
  attr_reader :object, :outside_dist
  attr_accessor :parent, :inside, :outside

  def initialize(object, distance_func)
    @object = object
    @distance_func = distance_func
    @parent = nil
    @inside = nil
    @outside = nil
    @outside_dist = nil
  end

  def insert(new_point)
    if @outside.nil?
      @outside = new_point
      @outside_dist = @distance_func.call(@object, new_point.object)
    elsif @distance_func.call(@object, new_point.object) < @outside_dist
      @inside = new_point
    else
      @outside.insert(new_point)
    end
  end

  def to_s
    inside_str = @inside.nil? ? "nil" : @inside
    outside_str = @outside.nil? ? "nil" : @outside
    "<#{@object}, #{inside_str}, #{outside_str}>"
  end
end
