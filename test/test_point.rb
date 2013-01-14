require 'minitest/autorun'
require 'nearby'

describe Nearby::Point, "point behavior" do
  before do
    @distance_func_1d = ->(x, y) do
      (y - x).abs
    end
  end

  describe "when creating a new point" do
    it "fails if no object is provided" do
      proc { new_point = Nearby::Point.new(@distance_func_1d) }.must_raise(ArgumentError)
    end

    it "initializes with correct fields when correct arugment provided" do
      new_point = Nearby::Point.new(1, @distance_func_1d)
      new_point.object.must_equal 1
      new_point.inside.must_be_nil
      new_point.outside.must_be_nil
    end
  end

  describe "when modifying a point" do
    it "allows read only for object" do
      new_point = Nearby::Point.new(1, @distance_func_1d)
      new_point.object.must_equal 1
      proc { new_point.object = 2 }.must_raise(NoMethodError)
    end
  end

  describe "when inserting a child point" do
    before do
      @base_point = Nearby::Point.new(1, @distance_func_1d)
    end

    it "inserts on the outside when outside is nil and sets radius and parent" do
      new_point = Nearby::Point.new(3, @distance_func_1d)
      @base_point.insert(new_point)
      @base_point.outside.must_equal new_point
      @base_point.radius.must_equal 2
    end

    it "recursively inserts on the outside when distance is greater then outside distance" do
      near_point = Nearby::Point.new(3, @distance_func_1d)
      far_point = Nearby::Point.new(5, @distance_func_1d)
      @base_point.insert(near_point)
      @base_point.insert(far_point)
      @base_point.outside.outside.must_equal far_point
    end

    it "recursively inserts on the inside when distance is less than outside distance" do
      outside_point = Nearby::Point.new(4, @distance_func_1d)
      first_inside_point = Nearby::Point.new(3, @distance_func_1d)
      second_inside_point = Nearby::Point.new(2, @distance_func_1d)
      @base_point.insert(outside_point)
      @base_point.insert(first_inside_point)
      @base_point.insert(second_inside_point)
      @base_point.inside.outside.must_equal second_inside_point
    end

    it "inserts on the inside when distance is less than outside distance" do
      first_outside_point = Nearby::Point.new(3, @distance_func_1d)
      second_outside_point = Nearby::Point.new(5, @distance_func_1d)
      first_inside_point = Nearby::Point.new(2, @distance_func_1d)
      second_inside_point = Nearby::Point.new(4, @distance_func_1d)
      @base_point.insert(first_outside_point)
      @base_point.insert(second_outside_point)
      @base_point.insert(first_inside_point)
      @base_point.insert(second_inside_point)
      @base_point.inside.must_equal first_inside_point
      @base_point.outside.inside.must_equal second_inside_point
    end
  end

  describe "when finding the nearest child point" do
    before do
      @base_point = Nearby::Point.new(1, @distance_func_1d)
      @outside_point = Nearby::Point.new(8, @distance_func_1d)
      @inside_point = Nearby::Point.new(2, @distance_func_1d)
      @base_point.insert(@outside_point)
      @base_point.insert(@inside_point)
    end

    it "follows inside path when object is inside radius" do
      context = Nearby::SearchContext.new(4)
      @base_point.insert(Nearby::Point.new(3, @distance_func_1d))
      @base_point.nearest(context)
      context.closest_object.must_equal 3
    end

    it "follows outside path when object is outside radius" do
      context = Nearby::SearchContext.new(10)
      @base_point.insert(Nearby::Point.new(9, @distance_func_1d))
      @base_point.nearest(context)
      context.closest_object.must_equal 9
    end

    it "follows outside path when object is not definitely inside radius" do
      context = Nearby::SearchContext.new(4)
      @base_point.insert(Nearby::Point.new(5, @distance_func_1d))
      @base_point.nearest(context)
      context.closest_object.must_equal 5
    end

    it "follows inside path when object is not definitely outside radius" do
      context = Nearby::SearchContext.new(7)
      @base_point.nearest(context)
      context.closest_object.must_equal 8
    end

    it "follows inside path when outside path generates too few results" do
      context = Nearby::SearchContext.new(9.5, 3)
      @base_point.insert(Nearby::Point.new(10, @distance_func_1d))
      @base_point.insert(Nearby::Point.new(5, @distance_func_1d))
      @base_point.nearest(context)
      context.closest_objects.must_equal [10, 8, 5]
    end
  end

  describe "when converting a point to a string" do
    it "returns string for an unattached point" do
      empty_point = Nearby::Point.new(1, @distance_func_1d)
      empty_point.to_s.must_equal '<1, nil, nil>'
    end

    it "returns string for an attached point" do
      parent_point = Nearby::Point.new(1, @distance_func_1d)
      parent_point.insert(Nearby::Point.new(3, @distance_func_1d))
      parent_point.insert(Nearby::Point.new(2, @distance_func_1d))
      parent_point.to_s.must_equal '<1, <2, nil, nil>, <3, nil, nil>>'
    end
  end
end
