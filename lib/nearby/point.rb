class Nearby::Point
  attr_reader :object, :radius, :inside, :outside

  def initialize(object, distance_func)
    @object = object
    @distance_func = distance_func
    @inside = nil
    @outside = nil
    @radius = nil
  end

  def insert(new_point)
    if @outside.nil?
      @outside = new_point
      @radius = @distance_func.call(@object, new_point.object)
    elsif @distance_func.call(@object, new_point.object) < @radius
      if @inside.nil?
        @inside = new_point
      else
        @inside.insert(new_point)
      end
    else
      @outside.insert(new_point)
    end
  end

  def nearest(search_context)
    distance_from_query = @distance_func.call(search_context.query_object, @object)

    search_context.suggest_object(@object, distance_from_query)

    unless @radius.nil?
      distance_to_radius = distance_from_query - @radius

      if distance_to_radius <= 0
        @more_likely = @inside
        @less_likely = @outside
      else
        @more_likely = @outside
        @less_likely = @inside
      end

      @more_likely.nearest(search_context) unless @more_likely.nil?
      if search_context.must_continue? || search_context.furthest_distance >= distance_to_radius.abs
        @less_likely.nearest(search_context) unless @less_likely.nil?
      end

    end

    search_context
  end

  def to_s
    inside_str = @inside.nil? ? 'nil' : @inside
    outside_str = @outside.nil? ? 'nil' : @outside
    "<#{ @object }, #{ inside_str }, #{ outside_str }>"
  end
end
