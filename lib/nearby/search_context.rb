require 'algorithms'

class Nearby::SearchContext
  attr_reader :query_object, :closest_distance, :closest_object

  def initialize(query_object, number_requested = 1)
    @query_object = query_object
    @number_requested = number_requested
    @closest_objects = Containers::MaxHeap.new
    @closest_object = nil
    @closest_distance = nil
  end

  def suggest_object(object, distance)
    if @closest_object.nil? || must_continue? || (distance < @closest_objects.next_key)
      @closest_objects.push(distance, object)

      @closest_objects.pop if @closest_objects.size > @number_requested

      if @closest_distance.nil? || distance < @closest_distance
        @closest_object = object
        @closest_distance = distance
      end
    end
  end

  def closest_objects
    reinsert_list =  []
    return_array = []

    while @closest_objects.next
      reinsert_list << [@closest_objects.next_key, @closest_objects.next]
      return_array << @closest_objects.pop
    end

    reinsert_list.each do |key, object|
      @closest_objects.push(key, object)
    end

    return_array.reverse
  end

  def furthest_distance
    @closest_objects.next_key
  end

  def must_continue?
    @closest_objects.size < @number_requested
  end
end
