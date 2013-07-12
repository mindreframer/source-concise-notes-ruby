$: << "../Containers" << "../Learning"
require "test/unit"
require "LinkedStack"
require "StringEnumerator"

module Recursion
  
  public
  
  # Recursive string reversal function
  # @pre: s is a string
  def reverse(s)
    return s if s.size <= 1
    return reverse(s[1..-1]) + s[0]
  end

  # Private functions for Towers of Hanoi solution
  private  
  
  def reset_hanoi
    @move_cnt = 0
  end
  
  def move_disk(src, dst)
    dst.push(src.pop)
    @move_cnt += 1
  end
  
  def num_hanoi_moves
    @move_cnt
  end
  
  public
  
  # Recursive solution for the Towers of Hanoi problem
  def move_tower(src, dst, aux, n)
    if n == 1
      move_disk(src,dst)
    else
      move_tower(src, aux, dst, n-1)
      move_disk(src, dst)
      move_tower(aux, dst, src, n-1)
    end
  end

  # Recursive factorial function illustrating tail recursion
  # @pre: 0 <= n
  def recursive_factorial(n)
    raise ArgumentError if n < 0
    (n <= 1) ? 1 : n * recursive_factorial(n-1)
  end
  
  # Non-recursive factorial function using a loop to replace
  # tail recursion.
  # @pre: 0 <= n
  def factorial(n)
    raise ArgumentError if n < 0
    product = 1
    n.downto(1).each { | i | product *=  i }
    product
  end
  
  # True iff string is string of balanced parentheses
  # This operation uses recursion
  # @pre: none
  def recursive_balanced?(string)
    return false if string =~ /[^\[\]]/
    return true if string.empty?
    source = StringEnumerator.new(string)
    check_balanced?(source) && source.empty?
  end
  
  # True iff string is string of balanced parentheses
  # This algorithm uses a stack
  # @pre: none
  def stack_balanced?(string)
    stack = LinkedStack.new
    string.chars do | ch |
      case
      when ch == '[' then stack.push(ch)
      when ch == ']'
        return false if stack.empty?
        stack.pop
      else return false
      end
    end
    stack.empty?
  end

  OPERATORS = /[+\-*\/%]/
  INVALID_CHARACTERS = /[^\d+\-*\/%]/
  INVALID_INFIX_CHARACTERS = /[^\d+\-*\/%()]/
  
  # Evaluate a simple prefix arithmetic expression using recursion
  # @pre: only digits and operators appear in string
  def recursive_eval_prefix(string)
    raise "Bad characters" if string =~ INVALID_CHARACTERS
    source = StringEnumerator.new(string)
    result = eval_prefix(source)
    raise "Extra characters at the end of the expression" unless source.empty?
    result
  end
   
  # Evaluate a simple prefix arithmetic expression using a stack
  # @pre: only digits and operators appear in string
  def stack_eval_prefix(string)
    raise "Bad characters" if string =~ INVALID_CHARACTERS
    raise "Missing expression" if string == nil || string.empty?
    op_stack = LinkedStack.new
    left_arg_stack = LinkedStack.new
    left_arg = right_arg = nil
    string.chars do | ch |
      case
      when ch =~ /\d/
        if left_arg == nil then left_arg = ch.to_i
        else
          right_arg = ch.to_i
          loop do
            raise "Missing operator" if op_stack.empty?
            right_arg = evaluate(op_stack.pop, left_arg, right_arg)
            if left_arg_stack.empty?
              left_arg = right_arg
              break
            else
              left_arg = left_arg_stack.pop
            end
          end
        end
      when ch =~ OPERATORS
        op_stack.push(ch)
        if left_arg != nil
          left_arg_stack.push(left_arg)
          left_arg = nil
        end
      end
    end
    raise "Missing argument" if !op_stack.empty?
    raise "Too many arguments" unless left_arg_stack.empty?
    raise "Missing expression" unless left_arg
    left_arg
  end
  
  # Evaluate a simple infix arithmetic expression using recursion
  # @pre: only digits and operators appear in string
  def recursive_eval_infix(string)
    raise "Bad characters" if string =~ INVALID_INFIX_CHARACTERS
    source = StringEnumerator.new(string)
    result = eval_infix(source)
    raise "Extra characters at the end of the expression" unless source.empty?
    result
  end
  
  # Evaluate a simple infix arithmetic expression using a stack
  # @pre: only digits and oeprators appear in string
  def stack_eval_infix(string)
    raise "Bad characters" if string =~ INVALID_INFIX_CHARACTERS
    op_stack = LinkedStack.new
    value_stack = LinkedStack.new
    string.chars do | ch |
      case
      when ch =~ /\d/ || ch == ')'
        if ch == ')'
          raise "Missing left parenthesis" if op_stack.empty? || op_stack.top != '('
          op_stack.pop
        else
          value_stack.push(ch.to_i)
        end
        while !op_stack.empty? && op_stack.top =~ OPERATORS
          op = op_stack.pop
          raise "Missing argument" if value_stack.empty?
          right_arg = value_stack.pop
          raise "Missing argument" if value_stack.empty?
          left_arg = value_stack.pop
          value_stack.push( evaluate(op, left_arg, right_arg) )
        end
      when ch =~ OPERATORS || ch == '('
        op_stack.push(ch)
      end
    end
    raise "Missing expression" if value_stack.empty?
    raise "Too many arguments" unless value_stack.size == 1
    raise "Missing argument" unless op_stack.empty?
    value_stack.pop
  end
  
  # Evaluate a simple postfix arithmetic expression using recursion
  # @pre: only digits and oeprators appear in string
  def recursive_eval_postfix(string)
    raise "Bad characters" if string =~ INVALID_CHARACTERS
    source = StringEnumerator.new(string)
    result = eval_postfix(source)
    raise "Extra characters at the end of the expression" unless source.empty?
    result
  end
  
  # Evaluate a simple postfix arithmetic expression using a stack
  # @pre: only digits and oeprators appear in string
  def stack_eval_postfix(string)
    raise "Bad characters" if string =~ INVALID_CHARACTERS
    stack = LinkedStack.new
    string.chars do | ch |
      case
      when ch =~ /\d/
        stack.push(ch.to_i)
      when ch =~ OPERATORS
        raise "Missing argument" if stack.empty?
        right_arg = stack.pop
        raise "Missing argument" if stack.empty?
        left_arg = stack.pop
        stack.push( evaluate(ch, left_arg, right_arg) )
      end
    end
    raise "Missing expresion" if stack.empty?
    raise "Too many arguments" unless stack.size == 1
    stack.pop
  end
  
  ##################################################################
  private
  
  # True iff @string is a non-empty string of balanced parentheses
  # @pre: source must be defined and may contain only [ and ]
  def check_balanced?(source)
    return false unless source.current == '['
    loop do
      if source.next == '['
        return false if !check_balanced?(source)
      end
      return false unless source.current == ']'
      break if source.next != '['
    end
    true
  end

  # Recursive helper to evaluate a simple prefix expression
  def eval_prefix(source)
    raise "Missing argument" if source.empty?
    ch = source.current
    source.next
    (ch =~ /\d/) ? ch.to_i : evaluate(ch, eval_prefix(source), eval_prefix(source))
  end

  # Recursive helper function to evaluate a simple infix expression
  def eval_infix(source)
    ch = source.current
    source.next
    if ch == '('
      left_arg = eval_infix(source)
      raise "Missing right parenthesis" unless source.current == ')'
      source.next
    elsif ch =~ /\d/
      left_arg = ch.to_i
    else
      raise "Missing argument"
    end
    while source.current =~ OPERATORS
      op = source.current
      ch = source.next
      if ch == '('
        source.next
        right_arg = eval_infix(source)
        raise "Missing right parenthesis" unless source.current == ')'
      elsif ch =~ /\d/
        right_arg = ch.to_i
      else
        raise "Missing argument"
      end
      left_arg = evaluate(op, left_arg, right_arg)
      source.next
    end
    left_arg
  end
  
  # Recursive helper to evaluate a simple postfix expression
  def eval_postfix(source)
    ch = source.current
    raise "Missing argument" unless ch =~ /\d/
    left_arg = ch.to_i
    while source.next =~ /\d/
      ch = source.current
      raise "Missing argument" unless ch =~ /\d/
      right_arg = ch.to_i
      ch = source.next
      raise "Missing operator" unless ch
      while !(ch =~ OPERATORS)
        source.back_up
        right_arg = eval_postfix(source)
        ch = source.current
        source.next
      end
      left_arg = evaluate(ch, left_arg, right_arg)
    end
    left_arg
  end
  
  # Helper to evaluate an expression given an operator (string) and two arguments (integers)
  def evaluate(op, left_arg, right_arg)
    case
    when op == '+' then return left_arg + right_arg
    when op == '-' then return left_arg - right_arg
    when op == '*' then return left_arg * right_arg
    when op == '/' then return left_arg / right_arg
    when op == '%' then return left_arg % right_arg
    end
  end
  
end

##################### Unit Tests #####################

class TestRecursion < Test::Unit::TestCase
  include Recursion
  
  def test_towers
    src = ("a".."h").to_a
    dst = []
    aux = []
    reset_hanoi
    move_tower(src,dst,aux,src.size)
    assert(src.empty?)
    assert(aux.empty?)
    assert_equal(("a".."h").to_a,dst)
    assert_equal(2**8-1,num_hanoi_moves)
  end
  def test_reverse
    assert_equal("",reverse(""))
    assert_equal("a",reverse("a"))
    assert_equal("abcd",reverse("dcba"))
  end
  
  def test_factorial
    assert_raises(ArgumentError) { recursive_factorial(-1) }
    assert_equal(1, recursive_factorial(0))
    assert_equal(1, recursive_factorial(1))
    assert_equal(120, recursive_factorial(5))
    assert_equal(2432902008176640000, factorial(20))
    assert_raises(ArgumentError) { factorial(-1) }
    assert_equal(1, factorial(0))
    assert_equal(1, factorial(1))
    assert_equal(120, factorial(5))
    assert_equal(2432902008176640000, factorial(20))
  end
  
  def test_balanced
    assert( recursive_balanced?("") )
    assert( recursive_balanced?("[]") )
    assert( recursive_balanced?("[][][]") )
    assert( recursive_balanced?("[[[]]]") )
    assert( recursive_balanced?("[[[][]][[[][][[]]]]]") )
    refute( recursive_balanced?("]") )
    refute( recursive_balanced?("[") )
    refute( recursive_balanced?("[]]") )
    refute( recursive_balanced?("[[]") )
    refute( recursive_balanced?("[[][]]]") )
    refute( recursive_balanced?("[][[[][]]][[][") )
    assert( stack_balanced?("") )
    assert( stack_balanced?("[]") )
    assert( stack_balanced?("[][][]") )
    assert( stack_balanced?("[[[]]]") )
    assert( stack_balanced?("[[[][]][[[][][[]]]]]") )
    refute( stack_balanced?("]") )
    refute( stack_balanced?("[") )
    refute( stack_balanced?("[]]") )
    refute( stack_balanced?("[[]") )
    refute( stack_balanced?("[[][]]]") )
    refute( stack_balanced?("[][[[][]]][[][") )
  end
  
  def test_prefix_eval
    assert_raises(RuntimeError) { recursive_eval_prefix("*8a") }
    assert_raises(RuntimeError) { recursive_eval_prefix("") }
    assert_raises(RuntimeError) { recursive_eval_prefix("*") }
    assert_raises(RuntimeError) { recursive_eval_prefix("*8") }
    assert_raises(RuntimeError) { recursive_eval_prefix("88") }
    assert_raises(RuntimeError) { recursive_eval_prefix("**98") }
    assert_raises(RuntimeError) { recursive_eval_prefix("8*") }
    assert_raises(RuntimeError) { recursive_eval_prefix("88*") }
    assert_raises(RuntimeError) { recursive_eval_prefix("*98*") }
    assert_equal(4, recursive_eval_prefix("4") )
    assert_equal(4, recursive_eval_prefix("*14") )
    assert_equal(10, recursive_eval_prefix("*2-83") )
    assert_equal(10, recursive_eval_prefix("*-832") )
    assert_equal(15, recursive_eval_prefix("*-83/93") )
    assert_raises(RuntimeError) { stack_eval_prefix("*8a") }
    assert_raises(RuntimeError) { stack_eval_prefix("") }
    assert_raises(RuntimeError) { stack_eval_prefix("*") }
    assert_raises(RuntimeError) { stack_eval_prefix("*8") }
    assert_raises(RuntimeError) { stack_eval_prefix("88") }
    assert_raises(RuntimeError) { stack_eval_prefix("**98") }
    assert_raises(RuntimeError) { stack_eval_prefix("8*") }
    assert_raises(RuntimeError) { stack_eval_prefix("88*") }
    assert_raises(RuntimeError) { stack_eval_prefix("*98*") }
    assert_equal(4, stack_eval_prefix("4") )
    assert_equal(4, stack_eval_prefix("*14") )
    assert_equal(10, stack_eval_prefix("*2-83") )
    assert_equal(10, stack_eval_prefix("*-832") )
    assert_equal(15, stack_eval_prefix("*-83/93") )
  end
  
  def test_postfix_eval
    assert_raises(RuntimeError) { recursive_eval_postfix("*8a") }
    assert_raises(RuntimeError) { recursive_eval_postfix("") }
    assert_raises(RuntimeError) { recursive_eval_postfix("*") }
    assert_raises(RuntimeError) { recursive_eval_postfix("*8") }
    assert_raises(RuntimeError) { recursive_eval_postfix("88") }
    assert_raises(RuntimeError) { recursive_eval_postfix("98**") }
    assert_raises(RuntimeError) { recursive_eval_postfix("8*") }
    assert_raises(RuntimeError) { recursive_eval_postfix("*88") }
    assert_raises(RuntimeError) { recursive_eval_postfix("*98*") }
    assert_equal(4, recursive_eval_postfix("4") )
    assert_equal(4, recursive_eval_postfix("14*") )
    assert_equal(10, recursive_eval_postfix("283-*") )
    assert_equal(10, recursive_eval_postfix("83-2*") )
    assert_equal(15, recursive_eval_postfix("83-93/*") )
    assert_raises(RuntimeError) { stack_eval_postfix("*8a") }
    assert_raises(RuntimeError) { stack_eval_postfix("") }
    assert_raises(RuntimeError) { stack_eval_postfix("*") }
    assert_raises(RuntimeError) { stack_eval_postfix("*8") }
    assert_raises(RuntimeError) { stack_eval_postfix("88") }
    assert_raises(RuntimeError) { stack_eval_postfix("98**") }
    assert_raises(RuntimeError) { stack_eval_postfix("8*") }
    assert_raises(RuntimeError) { stack_eval_postfix("*88") }
    assert_raises(RuntimeError) { stack_eval_postfix("*98*") }
    assert_equal(4, stack_eval_postfix("4") )
    assert_equal(4, stack_eval_postfix("14*") )
    assert_equal(10, stack_eval_postfix("283-*") )
    assert_equal(10, stack_eval_postfix("83-2*") )
    assert_equal(15, stack_eval_postfix("83-93/*") )
  end
  
  def test_infix_eval
    assert_raises(RuntimeError) { recursive_eval_infix("*8a") }
    assert_raises(RuntimeError) { recursive_eval_infix("") }
    assert_raises(RuntimeError) { recursive_eval_infix("*") }
    assert_raises(RuntimeError) { recursive_eval_infix("*8") }
    assert_raises(RuntimeError) { recursive_eval_infix("88") }
    assert_raises(RuntimeError) { recursive_eval_infix("98**") }
    assert_raises(RuntimeError) { recursive_eval_infix("8*") }
    assert_raises(RuntimeError) { recursive_eval_infix("*88") }
    assert_raises(RuntimeError) { recursive_eval_infix("*98*") }
    assert_raises(RuntimeError) { recursive_eval_infix("(") }
    assert_raises(RuntimeError) { recursive_eval_infix(")") }
    assert_raises(RuntimeError) { recursive_eval_infix("(8") }
    assert_raises(RuntimeError) { recursive_eval_infix("8)") }
    assert_raises(RuntimeError) { recursive_eval_infix("(4+)") }
    assert_raises(RuntimeError) { recursive_eval_infix("(+4)") }
    assert_equal(4, recursive_eval_infix("4") )
    assert_equal(4, recursive_eval_infix("(4)") )
    assert_equal(4, recursive_eval_infix("((4))") )
    assert_equal(4, recursive_eval_infix("1*4") )
    assert_equal(4, recursive_eval_infix("(2+2)") )
    assert_equal(4, recursive_eval_infix("((2)+2)") )
    assert_equal(4, recursive_eval_infix("(2+(2))") )
    assert_equal(10, recursive_eval_infix("8-3*2") )
    assert_equal(10, recursive_eval_infix("(8-3)*2") )
    assert_equal(2, recursive_eval_infix("8-(3*2)") )
    assert_equal(20, recursive_eval_infix("8-3*(9/2)") )
    assert_equal(22, recursive_eval_infix("8-3*9/2") )
    assert_equal(20, recursive_eval_infix("(8-3)*(9/2)") )
    assert_equal(22, recursive_eval_infix("(8-3*9/2)") )
    assert_raises(RuntimeError) { stack_eval_infix("*8a") }
    assert_raises(RuntimeError) { stack_eval_infix("") }
    assert_raises(RuntimeError) { stack_eval_infix("*") }
    assert_raises(RuntimeError) { stack_eval_infix("*8") }
    assert_raises(RuntimeError) { stack_eval_infix("88") }
    assert_raises(RuntimeError) { stack_eval_infix("98**") }
    assert_raises(RuntimeError) { stack_eval_infix("8*") }
    assert_raises(RuntimeError) { stack_eval_infix("*88") }
    assert_raises(RuntimeError) { stack_eval_infix("*98*") }
    assert_raises(RuntimeError) { stack_eval_infix("(") }
    assert_raises(RuntimeError) { stack_eval_infix(")") }
    assert_raises(RuntimeError) { stack_eval_infix("(8") }
    assert_raises(RuntimeError) { stack_eval_infix("8)") }
    assert_raises(RuntimeError) { stack_eval_infix("(4+)") }
    assert_raises(RuntimeError) { stack_eval_infix("(+4)") }
    assert_equal(4, stack_eval_infix("4") )
    assert_equal(4, stack_eval_infix("(4)") )
    assert_equal(4, stack_eval_infix("((4))") )
    assert_equal(4, stack_eval_infix("1*4") )
    assert_equal(4, stack_eval_infix("(2+2)") )
    assert_equal(4, stack_eval_infix("((2)+2)") )
    assert_equal(4, stack_eval_infix("(2+(2))") )
    assert_equal(10, stack_eval_infix("8-3*2") )
    assert_equal(10, stack_eval_infix("(8-3)*2") )
    assert_equal(2, stack_eval_infix("8-(3*2)") )
    assert_equal(20, stack_eval_infix("8-3*(9/2)") )
    assert_equal(22, stack_eval_infix("8-3*9/2") )
    assert_equal(20, stack_eval_infix("(8-3)*(9/2)") )
    assert_equal(22, stack_eval_infix("(8-3*9/2)") )
  end
end
