class Nearby::Space
  attr_reader :distance_func, :root

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

  def nearest(object, number_requested = 1)
    context = Nearby::SearchContext.new(object, number_requested)
    @root.nil? ? nil : @root.nearest(context).closest_objects
  end

  def to_s
    space_str = @root.nil? ? 'nil' : @root
    "Space: #{ space_str }"
  end
end
