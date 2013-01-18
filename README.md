Nearby
======

Nearby is a solution to the nearest neighbor optimization problem using a
vantage point tree.  Given any objects and a distance function, create a space
and then query for n nearest neighbors using any new object.

Usage Example
-------------

    > distance_function = ->(x, y) {(x - y).abs}
    > one_dimensional_space = Nearby::Space.new(distance_function)
    > one_dimensional_space.insert(1, 7, 9, 13, 21)
    > one_dimensional_space.nearest(12, 3)
     => [13, 9, 7]
