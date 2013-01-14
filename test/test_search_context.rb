require 'minitest/autorun'
require 'nearby'

describe Nearby::SearchContext, "search context behavior" do
  before do
    @context = Nearby::SearchContext.new(1)
  end

  describe "when creating a search context" do
    it "fails if no object is provided" do
      proc { Nearby::SearchContext.new }.must_raise(ArgumentError)
    end

    it "initializes with correct fields when object is provided" do
      @context.query_object.must_equal 1
      @context.closest_object.must_be_nil
      @context.closest_distance.must_be_nil
    end
  end

  describe "when suggesting closer objects" do
    it "sets own object and distance when own object is closer" do
      @context.suggest_object(5, 4)
      @context.suggest_object(2, 1)
      @context.closest_object.must_equal 2
    end

    it "does not modify object or distance if nothing closer exists" do
      @context.suggest_object(2, 1)
      @context.suggest_object(5, 4)
      @context.closest_object.must_equal 2
    end

    it "sets the closest object and distance" do
      @context.suggest_object(3, 2)
      @context.closest_object.must_equal 3
      @context.closest_distance.must_equal 2
      @context.suggest_object(2, 1)
      @context.closest_object.must_equal 2
      @context.closest_distance.must_equal 1
    end

    it "adds any object if number requested has not yet been found" do
      @find_three_context = Nearby::SearchContext.new(1, 3)
      @find_three_context.suggest_object(2, 1)
      @find_three_context.suggest_object(9, 8)
      @find_three_context.suggest_object(5, 4)
      @find_three_context.closest_objects.must_equal [2, 5, 9]
    end

    it "removes furthest result after number requested is reached" do
      @find_two_context = Nearby::SearchContext.new(1, 2)
      @find_two_context.suggest_object(9, 8)
      @find_two_context.suggest_object(2, 1)
      @find_two_context.closest_objects.must_equal [2, 9]
      @find_two_context.suggest_object(5, 4)
      @find_two_context.closest_objects.must_equal [2, 5]
    end
  end

  describe "when listing closest object results" do
    it "leaves structure intact when accessing closest_objects" do
      @find_two_context = Nearby::SearchContext.new(1, 2)
      @find_two_context.suggest_object(2, 1)
      @find_two_context.suggest_object(5, 4)
      @find_two_context.closest_objects.must_equal [2, 5]
      @find_two_context.closest_objects.must_equal [2, 5]
    end
  end
end
