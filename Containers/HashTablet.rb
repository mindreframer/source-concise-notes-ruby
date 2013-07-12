#
# A HashTablet is a "degenerate" hash table that stores arbitrary objects that are intended
# to icnlude both the key and the value. These pairs must be pckaged together in a Pair class
# that has a hash and == functions based on the key (these are called "appropriate" functions). 
#
# Author: C. Fox
# Version: November 2011

require "test/unit"
require "Iterator"

DEFAULT_TABLE_SIZE = 91

class HashTablet
  include Enumerable
  
  # Use chaining to resolve collisions; the table is an array of list
  # heads, and this is the linked list node type
  Node = Struct.new(:item, :next)
  
  # @pre: 7 <= tablet_size
  def initialize(table_size=DEFAULT_TABLE_SIZE)
    table_size = DEFAULT_TABLE_SIZE if table_size < 7
    @table = Array.new(table_size)
    @count = 0
  end
  
  # True iff this hash tablet has no elements
  def empty?
    @count == 0
  end
  
  # Table size (not the number of elements)
  def table_size
    @table.size
  end
  
  # How many elements are in the table now
  def size
    @count
  end
  
  # Set the table to empty, without changing the table size
  def clear
    @table = Array.new(@table.size)
    @count = 0
  end
  
  # Put an element into the tablet, replacing any element of equal value
  # @pre: element has an appropriate hash function and == operation
  # @return: element
  def insert(element)
    i = element.hash % @table.size
    node = @table[i]
    while node
      if element == node.item
        node.item = element
        return element
      end
      node = node.next
    end
    @table[i] = Node.new(element,@table[i])
    @count += 1
    return element
  end
  
  # Remove an element from the tablet, or do nothing if element not present
  # @pre: element has an appropriate hash function and == operation
  # @return: the value of the deleted element
  def delete(element)
    i = element.hash % @table.size
    return unless @table[i]
    if @table[i].item == element
      result = @table[i].item
      @table[i] = @table[i].next
      @count -= 1
      return result
    end
    node = @table[i]
    while node.next
      if element == node.next.item
        result = node.next.item
        node.next = node.next.next
        @count -= 1
        return result
      end
      node = node.next
    end
    return nil
  end
  
  # True iff element is in the table
  # @pre: element has an appropriate hash function and == operation
  def contains?(element)
    i = element.hash % @table.size
    node = @table[i]
    while node
      return true if element == node.item
      node = node.next
    end
    return false
  end
  
  # Obtain an item in the table equal to the argument element
  # @return: nil if no item equal to element is present
  # @pre: element has an appropriate hash function and == operation
  def get(element)
    i = element.hash % @table.size
    node = @table[i]
    while node
      return node.item if element == node.item
      node = node.next
    end
    return nil
  end
  
  # Enuerable each operation
  def each
    @table.each do |node|
      while node
        yield node.item
        node = node.next
      end
    end
  end
  
  # Return a copy of this tablet.
  def copy
    result = HashTablet.new(@table.size)
    each {|element| result.insert(element) }
    return result
  end
  alias dup copy
  
  # Return an external iterator for this hashtablet
  def iterator
    return HashTabletIterator.new(@table)
  end
  
  ########### External Iterator Class ##############
  
  class HashTabletIterator < Iterator
    
    # Make a new iterator object
    # table is the array used in the hashtablet
    def initialize(table)
      @table = table
      rewind
    end
    
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @index = 0
      @node = @table.size == 0 ? nil : @table[@index]
      while @index < @table.size and @node == nil
        @index += 1
        @node = @table[@index]
      end
    end
    
    # See whether iteration is complete
    def empty?
      return @node == nil
    end
    
    # Obtain the current element
    # @result: current element or nil if empty?
    def current
      return nil unless @node
      @node.item
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      return nil unless @node
      @node = @node.next
      while @index < @table.size and @node == nil
        @index += 1
        @node = @table[@index]
      end
      return @node == nil ? nil : @node.item
    end
  end
  
  ############## Helper Functions ##################
  
  def to_s
    result = ""
    each { |x| result += (result == "") ? x.to_s : ", "+x.to_s }
    return result
  end
  
  ############# Analysis Functions #################
  
  # Summarize features of the tablet
  def analyze
    max_chain = 0
    min_chain = @count
    num_chains = 0
    @table.each do |node|
      chain_length = 0
      num_chains += 1 if node
      while node
        node = node.next
        chain_length += 1
      end
      max_chain = chain_length if max_chain < chain_length
      min_chain = chain_length if chain_length < min_chain
    end
    return "Load factor: #{1.0*@count/@table.size}\n" +
           "Table density: #{1.0*num_chains/@table.size}\n" +
           "Mimumum chain: #{min_chain}\n" +
           "Maximum chain: #{max_chain}"
  end
end

##################### Unit Tests ########################
#=begin
class TestHashTablet < Test::Unit::TestCase
  class Pair
    attr_accessor :key, :value
    def initialize(key, value)
      @key, @value = key, value
    end
    def==(other)
      key==other.key
    end
    def hash
      key.hash
    end
  end
  
  def test_ops
    t = HashTablet.new
    assert(t.empty?)
    assert_equal(0, t.size)
    assert_equal(91, t.table_size)
    e = Pair.new("abc",1)
    t.insert(e)
    e = Pair.new("def",2)
    t.insert(e)
    e = Pair.new("ghi",3)
    t.insert(e)
    e = Pair.new("jkl",4)
    t.insert(e)
    refute(t.empty?)
    assert_equal(4, t.size)
    e = Pair.new("jfg",9)
    refute(t.contains?(e))
    e.key,e.value = "jkl",20
    assert(t.contains?(e))
    g = Pair.new("aaa",0)
    t.delete(g)
    assert_equal(4, t.size)
    t.delete(e)
    refute(t.contains?(e))
    assert_equal(3, t.size)
    assert_equal(nil, t.get(e))
    t.insert(g)
    e.key = g.key
    f = t.get(e)
    assert_equal("aaa", f.key)
    assert_equal(0, f.value)
    count = 0
    t.each { count+=1 }
    assert_equal(count, t.size)
    s = t.dup
    assert_equal(s.size, t.size)
    s.each { |x| assert(t.contains?(x)) }
  end

  def test_chains()
    t = HashTablet.new(19)
    0.upto(50) { |x| t.insert(x) }
    0.upto(50) { |x| assert(t.contains?(x)) }
    assert_equal(t.count,t.size)
    iter = t.iterator
    t.each do |x|
      assert_equal(x, iter.current)
      refute(iter.empty?)
      iter.next
    end
    assert(iter.empty?)
    a = []
    t.each { |x| a[x] = x }
    assert_equal(51,a.size)
    0.upto(50) {|x| assert_equal(x,a[x]) }
    t.delete(20)
    t.delete(27)
    t.delete(42)
    assert_equal(48,t.size)
    refute(t.contains?(27))
    assert_equal(t.count,t.size)
  end
end
#=end