#
# Binary search trees are used as implementation data structures.
#
# Author: C. Fox
# Version: July 2011

#require "test/unit"
require "BinaryTree"

class BinarySearchTree < BinaryTree
  
  # @inv: for every node:
  #         - if node.left, then node.left.value <= node.value
  #         - if node.right, then node.value <= node.right.value

  # Set up an empty tree
  # @pre: left subtree root value <= value
  # @pre: right subtree root value >= value
  def initialize(value=nil, left=nil, right=nil)
    if value == nil
      @root = nil
      @count = 0
    else
      if left && !left.empty? && value < left.root_value
        return ArgumentError, "Invalid left tree root value"
      end
      if right && !right.empty? && right.root_value < value
        return ArgumentError, "Invalid right tree root value"
      end 
      @root = Node.new(value, (left == nil ? nil : left.structure), (right == nil ? nil : right.structure))
      @count = 1 + (left == nil ? 0 : left.size) + (right == nil ? 0 : right.size)
    end
  end
  
  # Returns true iff the element is stored at a tree node
  def contains?(element)
    node = @root
    while node
      return true if node.value == element
      node = element < node.value ? node.left : node.right
    end
    return false
  end
  
  # Return the value stored at a node equal to element, or nil if none
  def get(element)
    node = @root
    while node
      return node.value if node.value == element
      node = element < node.value ? node.left : node.right
    end
    return nil
  end
  
  # Insert the element into the binary search tree, or replace it with
  # the element if a value equal to element is already present
  def add(element)
    if @root == nil
      @root = Node.new(element)
      @count += 1
      return element
    end
    node = @root
    loop do
      if node.value == element
        node.value = element
        return element
      elsif element < node.value
        if node.left == nil
          node.left = Node.new(element)
          @count += 1
          return element
        else
          node = node.left
        end
      else # node.value < element
        if node.right == nil
          node.right = Node.new(element)
          @count += 1
          return element
        else
          node = node.right
        end
      end
    end
  end
  
  # Remove the element from the tree, or do nothing if it is not present
  # @return: removed value, or nil if nothing is done
  def remove(element)
    # find the node with the element, if any
    parent, node = nil, @root
    while node
      break if element == node.value
      parent = node
      node = element < node.value ? node.left : node.right
    end
    return nil if node == nil
    
    # the element is present, so remove it
    value = node.value
    if node.left == nil # removed node has at most one child
      if parent == nil
        @root = node.right
      else
        if parent.left == node
          parent.left = node.right
        else
          parent.right = node.right
        end
      end
    elsif node.right == nil # removed node has one child
      if parent == nil
        @root = node.left
      else
        if parent.left == node
          parent.left = node.left
        else
          parent.right = node.left
        end
      end
    else # removed node has two children
      target = parent = node
      node = node.right
      while node.left
        parent = node
        node = node.left
      end
      target.value = node.value
      if parent == target
        parent.right = node.right
      else
        parent.left = node.right
      end
    end
    @count -= 1
    return value
  end
  
  # Returns a BinarySearchTree that is a copy of this tree
  def dup
    result = BinarySearchTree.new
    result.set_root(structure)
    return result
  end
  
end

#########################  Unit Tests ##########################
=begin
class TestBinarySearchTree < Test::Unit::TestCase

  def test_basic_ops
    t = BinarySearchTree.new
    assert(t.empty?)
    assert_equal(nil, t.get("a"))
    t = BinarySearchTree.new("a")
    assert(!t.empty?)
    assert(t.contains?("a"))
    assert(!t.contains?("b"))
    assert_equal("a", t.get("a"))
    assert_equal(nil, t.get("b"))
    s = BinarySearchTree.new("c")
    t = BinarySearchTree.new("b",t,s)
    assert(!t.empty?)
    assert(t.contains?("c"))
    assert(!t.contains?("d"))
    t = BinarySearchTree.new("d",t,BinarySearchTree.new("e"))
    assert_equal("a", t.get("a"))
    assert_equal("c", t.get("c"))
    assert_equal("e", t.get("e"))
    assert_equal(nil, t.get("f"))
    t.add("m")
    t.add("j")
    t.add("p")
    t.add("w")
    t.add("s")
    t.add("g")
    t.add("d")
    t.add("w")
    assert_equal(11, t.size)
    assert_equal(5, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcdegjmpsw', s)
    t.remove("f")
    assert_equal(11, t.size)
    assert_equal(5, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcdegjmpsw', s)
    t.remove("d")
    assert_equal(10, t.size)
    assert_equal(4, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcegjmpsw', s)
    t.remove("w")
    assert_equal(9, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcegjmps', s)
    t.remove("e")
    assert_equal(8, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("j"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcgjmps', s)
    t.remove("j")
    assert_equal(7, t.size)
    assert_equal(3, t.height)
    assert(t.contains?("c"))
    assert(t.contains?("s"))
    s = ""
    t.each { |ch| s += ch }
    assert_equal('abcgmps', s)
    t.clear
    t.add("a")
    assert_equal(1,t.size)
    assert_equal(0,t.height)
    t.remove("a")
    assert(t.empty?)
  end
end
=end