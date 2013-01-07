require 'minitest/autorun'
require 'nearby'

describe Nearby::Space, "space behavior" do
  before do
    @distance_func_2d = ->(a, b) do
      x = (a[0] - b[0]).abs
      y = (a[1] - b[1]).abs
      Math.sqrt( x * x + y * y )
    end
  end

  describe "when creating a new space" do
    it "fails if no distance function is provided" do
      proc { Nearby::Space.new() }.must_raise(ArgumentError)
    end

    it "sets a distance function when provided" do
      space = Nearby::Space.new(@distance_func_2d)
      space.distance_func.call([1, 1], [2, 2]).must_equal Math.sqrt(2)
    end
  end

  describe "when inserting an object into a space" do
    before do
      @space = Nearby::Space.new(@distance_func_2d)
    end

    it "can insert into root when space is empty" do
      @space.root.must_equal nil
      @space.insert(1)
      @space.root.object.must_equal 1
    end

    it "can insert multiple times" do
      expected_string = "Space: <[1, 1], <[2, 2], nil, nil>, " +
                                        "<[3, 3], nil, <[4, 4], nil, nil>>>"
      @space.root.must_equal nil
      @space.insert([1, 1])
      @space.insert([3, 3], [2, 2])
      @space.insert([4, 4])
      @space.to_s.must_equal expected_string
    end
  end

  describe "when formatting the space into a string" do
    it "returns when space is empty" do
      empty_space = Nearby::Space.new(@distance_func_2d)
      empty_space.to_s.must_equal "Space: nil"
    end
  end
end
