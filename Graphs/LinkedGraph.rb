#
# Linked implementation of a graph. This class uses the adjacency lists representation
# of undirected graphs to realize a graph with n vertices.
#
# Author: C. Fox
# Version: August 2012

$: << "../Containers"
require "Graph"
require "LinkedList"
require "test/unit"

class LinkedGraph < Graph
  
  # Set up the adjacency lists data structure
  def initialize(n)
    @vertices = n
    @edges = 0
    @adjacent = []
    0.upto(n-1) { |i| @adjacent[i] = LinkedList.new }
  end
  
  # Put an edge {v,w} into the graph
  def add_edge(v,w)
    raise ArgumentError, "No such vertex" if v < 0 or @vertices <= v
    raise ArgumentError, "No such vertex" if w < 0 or @vertices <= w
    raise ArgumentError, "No such edge" if v == w
    @adjacent[v].insert(0,w)
    @adjacent[w].insert(0,v)
    @edges += 1
  end
  
  # Return true iff there is an edge {v,w} in the graph
  def edge?(v,w)
    return false if v < 0 or @vertices <= v
    return false if w < 0 or @vertices <= w
    return false if v == w
    return @adjacent[v].contains?(w)
  end
  
  # Iterate over the edges adcanet to v
  def each_edge(v)
    raise ArgumentError, "No such vertex" if v < 0 or @vertices <= v
    @adjacent[v].each { |w| yield v,w }
  end
  
  # Represent the graph as a string
  def to_s
    result = ""
    @adjacent.each_with_index do |list,v|
      result += v.to_s + ":"
      list.each do |w|
        result += " "+w.to_s
      end
      result += "\n"
    end
    result
  end
  
end

####################  Unit Tests #####################
#=begin
class TestArrayGraph < Test::Unit::TestCase

  def test_graph_ops
    # test basic ops
    g = LinkedGraph.new(20)
    assert_equal(20, g.vertices)
    assert_equal(0, g.edges)
    a = [0, 4, 7, 11, 15, 19]
    a.each { |w| g.add_edge(2,w) }
    assert_equal(a.size,g.edges)
    a.each { |w| assert(g.edge?(2,w)) }
    a.each { |w| assert(g.edge?(w,2)) }
    assert(!g.edge?(2,5))
    assert(!g.edge?(5,2))
    assert(!g.edge?(2,2))
    assert(!g.edge?(2,50))
    assert(!g.edge?(2,-3))

    # test edge iteration
    i = a.size-1
    g.each_edge(2) do |v,w|
      assert_equal(v,2)
      assert_equal(w,a[i])
      i -= 1
    end
    assert_equal(i,-1)
  end
  
  def test_algorithms
    g = LinkedGraph.new(10)
    g.add_edge(0,1)
    g.add_edge(0,3)
    g.add_edge(2,3)
    g.add_edge(4,3)
    g.add_edge(3,5)
    g.add_edge(4,5)
    g.add_edge(6,7)
    g.add_edge(8,7)
    g.add_edge(8,9)
    assert(!g.path?(3,6))
    assert(!g.path?(6,3))
    assert(g.path?(5,1))
    assert(g.path?(1,5))
    assert(!g.connected?)
    g.add_edge(2,8)
    g.add_edge(3,6)
    assert(g.connected?)
  
    path = g.shortest_path(0,9)
    assert_equal([0,3,2,8,9],path)
    path = g.shortest_path(5,7)
    assert_equal([5,3,6,7],path)
    h = g.spanning_tree
    assert(h.connected?)
  end

end