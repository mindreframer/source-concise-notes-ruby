#
# A HashMap uses a HashTablet to hold the values in the map.
# Keys in the key-value pair used in a HashMap must have
# appropiate hash and == functions.
#
# Author: C. Fox
# Version: Novmber 2011

require "test/unit"
require "Iterator"
require "Map"
require "HashTablet"

class HashMap < Map
  
  ###################### Pair Class ########################
  # The HashMap holds the key-value pair in a pair class
  # whose hash and == operations use the key only.
  
  Pair = Struct.new(:key, :value)
  
  class Pair
    def ==(other)
      return self.key == other.key
    end
    
    def hash()
      return key.hash
    end
  end
    
  ###################  Object Operations ###################
  
  DEFAULT_TABLE_SIZE = 91
  
  # Set up a new HashMap
  def initialize(size=DEFAULT_TABLE_SIZE)
    @tablet = HashTablet.new(size)
  end
  
  # Print the contents of this map
  def to_s
    result = "[ "
    @tablet.each do | pair |
      result += "("+ pair.key.to_s + "," + pair.value.to_s + ") "
    end
    result += "]"
    return result
  end
  
  ################## Container Operations ###################
  
  # Return the number of entities in the map
  def size
    return @tablet.size
  end
  
  # Make the map empty
  # @return: 0
  def clear
    @tablet.clear
    return 0
  end
  
  ################### Collection Operations #################
  
  # Return an external iterator object for this map
  def iterator()
    return HashMapIterator.new(@tablet)
  end
  
  # Return true iff this map is the same as another
  def ==(other)
    return false unless other
    return false unless @tablet.size == other.size
    @tablet.each do |this_pair|
      return false unless other[this_pair.key] == this_pair.value
    end
    return true
  end
  
  ##################### Map Operations ######################
  
  # Return the value with the indicated key, or nil if none
  def [](key)
    dummy = Pair.new(key,nil)
    pair = @tablet.get(dummy)
    return nil unless pair
    return pair.value
  end
  
  # Add a key-value pair to the map; replace the value if a pair with the key is already present
  # @return: value
  def []=(key, value)
    pair = Pair.new(key,value)
    @tablet.insert(pair)
    return value
  end
  
  # Remove the pair with the designated key from the map, or do nothing if key not present
  # @return: the value of the deleted pair, or nil if the key is not present
  def delete(key)
    dummy = Pair.new(key,nil)
    pair = @tablet.delete(dummy)
    return nil unless pair
    return pair.value
  end
  
  # Return true iff the key is present in the map
  def has_key?(key)
    dummy = Pair.new(key,nil)
    return @tablet.get(dummy)
  end
  
  # Return true iff the value is present in the map
  def has_value?(value)
    each do | k, v |
      return true if v == value
    end
    return false
  end
  
  # Return true iff an element is present in this map
  alias contains? has_value?

  ################### Enumerable Operations ################
  
  def each(&b)
    @tablet.each do |pair|
      b.call(pair.key, pair.value)
    end
  end
  
  ################### External Iterators ###################
  
  class HashMapIterator < Iterator
    
    # Set up a new tablet map iterator
    # @pre: tablet is a BinarySearchTablet
    def initialize(tablet)
      raise ArgumentError, "Bad iterator argument" unless tablet.class == HashTablet
      @tablet_iterator = tablet.iterator
      rewind
    end
    
    # Prepare for an iteration
    # @post: current == first item in Collection if !empty?
    def rewind
      @tablet_iterator.rewind
    end
    
    # See whether iteration is complete
    def empty?
      return @tablet_iterator.empty?
    end
    
    # Obtain the current piar as an array with the key and value
    # @result: current element or nil if empty?
    def current
      return nil if empty?
      pair = @tablet_iterator.current
      return [pair.key, pair.value]
    end
  
    # Move to the next element
    # @result: next element or nil if empty?
    def next
      return @tablet_iterator.next
    end
  end
  
end

####################### Unit Tests #########################
=begin
class TestHashMap < Test::Unit::TestCase
  def test_basic
    s = HashMap.new
    t = HashMap.new
    assert_equal(0, s.size)
    assert(s.empty?)
    assert(!s.has_key?(:a))
    assert(!s.has_value?(4))
    assert(t==s)
    assert(s==t)
    s[:m] = 8
    assert_equal(1, s.size)
    assert(!s.empty?)
    assert(s.has_key?(:m))
    assert(s.has_value?(8))
    s[:g] = 1
    s[:t] = 32
    s[:g] = 2
    s[:c] = 1
    s[:k] = 256
    s[:w] = 64
    s[:p] = 16
    s[:k] = 4
    assert_equal(7, s.size)
    assert_equal(nil, s[:none])
    assert_equal(1, s[:c])
    assert_equal(2, s[:g])
    assert_equal(4, s[:k]) 
    assert_equal(8, s[:m])
    assert_equal(16,s[:p])
    assert_equal(32,s[:t])
    assert_equal(64,s[:w])
    assert(s.has_key?(:k))
    assert(s.has_key?(:w))
    assert(s.has_key?(:c))
    assert(!s.has_key?(:a))
    t[:p] = 16
    t[:c] = 1
    t[:g] = 2
    t[:k] = 4
    t[:w] = 64
    refute(s==t)
    refute(t==s)
    t[:t] = 32
    t[:m] = 8
    assert(s==t)
    assert(t==s)
    assert_equal(nil, s.delete(:a))
    assert_equal(64, s.delete(:w))
    assert_equal(6, s.size)
    refute(s==t)
    assert_equal(1, s.delete(:c))
    assert_equal(8, s.delete(:m))
    assert_equal(4, s.size)
  end
  
  def test_iterators
    s = HashMap.new
    s[:m] = 8
    s[:t] = 32
    s[:g] = 2
    s[:c] = 1
    s[:w] = 64
    s[:p] = 16
    s[:k] = 4
    assert(s.has_key?(:k))
    assert(s.has_key?(:w))
    assert(s.has_key?(:c))
    assert(!s.has_key?(:a))
    assert(s.has_value?(32))
    assert(s.has_value?(2))
    assert(s.contains?(1))
    assert(!s.contains?(7))
    count = 0
    s.each { |key, value| count += 1 }
    assert_equal(7,count)
    iter = s.iterator
    count = 0
    while !iter.empty?
      array = iter.current
      count += 1
      iter.next
    end
    assert_equal(7,count)
  end
  
end
=end