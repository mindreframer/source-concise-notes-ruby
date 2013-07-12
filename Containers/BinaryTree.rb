#
# Binary trees are used as implementation data structures.
#
# Author: C. Fox
# Version: July 2011

#require "test/unit"
require "Iterator"
require "LinkedStack"

class BinaryTree
  include Enumerable
  
  # Create a node class for making a linked binary tree
  Node = Struct.new(:value, :left, :right)
  
  # @inv: 0 <= count
  # @inv: root is null iff 0 == count

  # Set up a new tree; value is the datum stored at the root node
  # @pre: left and right are binary trees
  def initialize(value=nil, left=nil, right=nil)
    raise ArgumentError, "Left sub-tree is not a BinaryTree" unless left == nil || left.class == BinaryTree
    raise ArgumentError, "Right sub-tree is not a BinaryTree" unless right == nil || right.class == BinaryTree
    if value == nil
      @root = nil
      @count = 0
    else
      @root = Node.new(value, (left ? left.structure : nil), (right ? right.structure : nil))
      @count = 1 + (left ? left.size : 0) + (right ? right.size : 0)
    end
  end
  
  ##################### Object Oerations ###################
  
  # Return true if a tree has the same shape with the same
  # values at the nodes as another.
  def ==(other)
    return false unless other
    return false unless @count == other.size
    equal_structure?(@root,other.structure)
  end
  
  # List the contents of the tree in order
  def to_s
    result = ""
    each { |x| result += (result == "") ? x.to_s : ", "+x.to_s }
    return result
  end
  
  ################## Binary Tree Operations ##################
  
  # True iff there are no nodes
  def empty?
    @count == 0
  end
  
  # Height of a node with no children is 0; height of a tree is 1+height of
  # its tallest non-empty child
  def height
    structure_height(@root)
  end
  
  # Returns the value at the root of the tree
  # @pre: !empty?
  def root_value
    raise RuntimeError, "Empty trees have no root value" unless @root
    @root.value
  end
  
  # Returns a BinaryTree that is a copy of the left subtree
  # @pre: !empty?
  def left_subtree
    raise RuntimeError, "Empty trees have no left sub-tree" if empty?
    result = BinaryTree.new
    new_root = dup_structure(@root.left)
    result.set_root(new_root)
    return result
  end
  
  # Returns a BinaryTree that is a copy of the right subtree
  # @pre: !empty?
  def right_subtree
    raise RuntimeError, "Empty trees have no right sub-tree" if empty?
    result = BinaryTree.new
    new_root = dup_structure(@root.right)
    result.set_root(new_root)
    return result
  end
  
  # Returns a BinaryTree that is a copy of this tree
  def dup
    result = BinaryTree.new
    result.set_root(structure)
    return result
  end
  
  # Returns the number of nodes in the tree
  def size
    @count
  end
  
  # Makes the tree into the empty tree
  def clear
    @root = nil
    @count = 0
  end
  
  # Returns true iff v is stored at a node in the tree
  def contains?(element)
    structure_contains?(element,@root)
  end
  
  #################### Eumerable Operations #####################
  
  def each_preorder(&block)
    each_preorder_structure(@root,block)
  end
  
  def each_inorder(&block)
    each_inorder_structure(@root,block)
  end
  
  def each_postorder(&block)
    each_postorder_structure(@root,block)
  end
  
  alias each each_inorder
  
  ######################### Iterators ##########################
  
  class PreorderIterator < Iterator ############################
    
    # Create a new iterator
    def initialize(node)
      @root = node
      @stack = LinkedStack.new
      rewind
    end
    
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @stack.clear
      @stack.push(@root) if @root
    end
    
    # See whether iteration is complete
    def empty?
      @stack.empty?
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      return nil if @stack.empty?
      @stack.top.value
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      node = @stack.empty? ? nil : @stack.pop
      return if node == nil
      @stack.push(node.right) if node.right != nil
      @stack.push(node.left) if node.left != nil
    end
  end
  
  # Return a new preorder external iterator
  def preorder_iterator
    PreorderIterator.new(@root)
  end
  
  class InorderIterator < Iterator #############################
      
    # Create a new iterator
    def initialize(node)
      @root = node
      @stack = LinkedStack.new
      rewind
    end
      
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @stack.clear
      node = @root
      while node
        @stack.push(node)
        node = node.left
      end
    end
      
    # See whether iteration is complete
    def empty?
      @stack.empty?
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      return nil if @stack.empty?
      @stack.top.value
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      node = @stack.empty? ? nil : @stack.pop.right
      while node
        @stack.push(node)
        node = node.left
      end
    end
  end
  
  # Return a new inorder external iterator
  def inorder_iterator
    InorderIterator.new(@root)
  end
    
  # The default iterator is an inorder iterator
  alias iterator inorder_iterator
  
  class PostorderIterator < Iterator #############################
      
    # Create a new iterator
    def initialize(node)
      @root = node
      @stack = LinkedStack.new
      rewind
    end
      
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @stack.clear
      node = @root
      while node
        @stack.push(node)
        node = node.left ? node.left : node.right
      end
    end
      
    # See whether iteration is complete
    def empty?
      @stack.empty?
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      return nil if @stack.empty?
      @stack.top.value
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      node = @stack.empty? ? nil : @stack.pop
      return if node == nil || @stack.empty?
      if node != @stack.top.right
        node = @stack.top.right
        while node
          @stack.push(node)
          node = node.left ? node.left : node.right
        end
      end
    end
  end
  
  # Return a new post order external iterator
  def postorder_iterator
    PostorderIterator.new(@root)
  end
  
  ####################### Helper Functions #######################
  
  protected
   
  # Return a copy of the linked tree structure of this binary tree
  def structure
    dup_structure(@root)
  end
  
  # Assign the @root of a binary tree and adjust @count
  def set_root(root)
    @root = root
    @count = structure_count(@root)
  end
  
  private
   
  # Recursively compute and return the height of a tree structure
  def structure_height(node)
    return 0 unless node
    return 0 if node.left == nil and node.right == nil
    left_height = structure_height(node.left)
    right_height = structure_height(node.right)
    ((left_height < right_height) ? right_height : left_height) + 1
  end
  
  # Recursively compute and return the number of nodes in a tree structure
  def structure_count(node)
    return 0 unless node
    return 1 + structure_count(node.left) + structure_count(node.right)
  end
  
  # Recursively make and return a copy of the linked tree structure
  def dup_structure(node)
    return nil unless node
    Node.new(node.value, dup_structure(node.left), dup_structure(node.right))
  end
  
  # Return true iff two tree structures have the same shape with the same values
  def equal_structure?(node1,node2)
    return true if node1 == nil && node2 == nil
    return false if (node1 == nil || node2 == nil)
    return false if node1.value != node2.value
    equal_structure?(node1.left,node2.left) && equal_structure?(node1.right,node2.right)
  end
  
  # Return iff a tree structure contains a value
  def structure_contains?(element, node)
    return false unless node
    return true if element == node.value
    structure_contains?(element,node.left) || structure_contains?(element,node.right)
  end
  
  # Apply a proc to the values in a tree structure in preorder
  # @pre: proc != nil
  def each_preorder_structure(node, proc)
    return unless node
    proc.call(node.value)
    each_preorder_structure(node.left,proc)
    each_preorder_structure(node.right,proc)
  end
  
  # Apply a proc to the values in a tree structure inorder
  # @pre: proc != nil
  def each_inorder_structure(node, proc)
    return unless node
    each_inorder_structure(node.left,proc)
    proc.call(node.value)
    each_inorder_structure(node.right,proc)
  end
  
  # Apply a proc to the values in a tree structure in postorder
  # @pre: proc != nil
  def each_postorder_structure(node, proc)
    return unless node
    each_postorder_structure(node.left,proc)
    each_postorder_structure(node.right,proc)
    proc.call(node.value)
  end
end

########################  Unit Tests #########################
=begin
class TestBinaryTree < Test::Unit::TestCase

  def test_basic_ops
    t = BinaryTree.new
    assert(t.empty?)
    assert_equal(0, t.size)
    assert_equal(0, t.height)
    assert_raise(RuntimeError) { t.root_value }
    assert_raise(RuntimeError) { t.left_subtree }
    assert_raise(RuntimeError) { t.right_subtree }
    s = t.dup
    assert(s.empty?)
    assert_equal(0, s.size)
    assert_equal(0, s.height)
    assert_raise(RuntimeError) { s.root_value }
    assert_raise(RuntimeError) { s.left_subtree }
    assert_raise(RuntimeError) { s.right_subtree }
    t = BinaryTree.new("a")
    assert(!t.empty?)
    assert_equal(1, t.size)
    assert_equal(0, t.height)
    assert_equal("a", t.root_value)
    assert(t.left_subtree.empty?)
    assert(t.right_subtree.empty?)
    assert(t.contains?("a"))
    assert(!t.contains?("b"))
    s = BinaryTree.new("c")
    t = BinaryTree.new("b",t,s)
    assert(!t.empty?)
    assert_equal(1, t.height)
    assert_equal(3, t.size)
    assert_equal("b", t.root_value)
    assert_equal(s, t.right_subtree)
    assert(t.contains?("c"))
    assert(!t.contains?("d"))
    t = BinaryTree.new("d",t,BinaryTree.new("e"))
    p  t.left_subtree.class
    assert_equal(2, t.height)
    assert_equal(5, t.size)
    assert_equal("d", t.root_value)
    s = t.dup
    assert_equal(2, s.height)
    assert_equal(5, s.size)
    assert_equal("d", s.root_value)
    assert(s.contains?("d"))
    assert(!s.contains?("f"))
    str = ""
    t.each_preorder { |ch| str += ch }
    assert_equal('dbace', str)
    str = ""
    t.each_inorder { |ch| str += ch }
    assert_equal('abcde', str)
    str = ""
    t.each { |ch| str += ch }
    assert_equal('abcde', str)
    str = ""
    t.each_postorder { |ch| str += ch }
    assert_equal('acbed', str)
    str = ""; i = t.preorder_iterator
    while !i.empty?
      str += i.current
      i.next
    end
    assert_equal('dbace', str)
    str = ""; i = t.inorder_iterator
    while !i.empty?
      str += i.current
      i.next
    end
    assert_equal('abcde', str)
    str = ""; i = t.postorder_iterator
    while !i.empty?
      str += i.current
      i.next
    end
    assert_equal('acbed', str)
  end
end
=end
