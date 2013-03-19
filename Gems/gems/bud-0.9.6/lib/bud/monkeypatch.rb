# We monkeypatch Module to add support for Bloom's syntax additions: "state",
# "bloom", and "bootstrap" blocks, plus the "import" statement.

require 'bud/source'

class Class
  def modules
    a = self.ancestors
    a[1..a.index(superclass)-1]
  end
end

# FIXME: Use a subclass of Struct.
# FIXME: Should likely override eql? as well
class Struct
  def <=>(o)
    if o.class == self.class
      self.each_with_index do |e, i|
        cmp = e <=> o[i]
        return cmp if cmp != 0
      end
      return 0
    elsif o.nil?
      return -1
    else
      raise "Comparison (<=>) between #{o.class} and #{self.class} not implemented"
    end
  end

  alias oldeq :==
  def ==(o)
    if o.class == self.class
      return oldeq(o)
    elsif o.class == Array
      begin
        self.each_with_index do |el, i|
          if el != o[i]
            return false
          end
        end
        return true
      rescue StandardError
        return false
      end
    end
    false
  end

  def to_msgpack(out=nil)
    self.to_a.to_msgpack(out)
  end

  def inspect
    self.to_a.inspect
  end

  alias :to_s :inspect
end

# XXX: TEMPORARY/UGLY hack to ensure that arrays and structs compare. This can be
# removed once tests are rewritten.
class Array
  alias :oldeq :==
  def ==(o)
    if o.kind_of? Struct
      o = o.to_a
    end
    self.oldeq(o)
  end
end


$moduleWrapper = {} # module => wrapper class.  See import below.
class Module
  def modules
    ancestors[1..-1]
  end

  # import another module and assign to a qualifier symbol: <tt>import MyModule => :m</tt>
  def import(spec)
    raise Bud::CompileError unless (spec.class <= Hash and spec.length == 1)
    mod, local_name = spec.first
    raise Bud::CompileError unless (mod.class <= Module and local_name.class <= Symbol)
    if mod.class <= Class
      raise Bud::CompileError, "import must be used with a Module, not a Class"
    end

    # A statement like this:
    #   import MyModule => :m
    # is translated as follows. First, module MyModule is made instantiable by wrapping it in a class
    #   class MyModule__wrap__
    #     include Bud
    #     include MyModule
    #   end
    #
    # Then introduce a method "m", the import binding name, in the calling module/class
    # (the one with the import statement). This returns an instance of the wrapped class.
    #   inst = MyModule__wrap__.new
    #   def m
    #      inst
    #   end

    mod, local_name = spec.first

    if self.method_defined? local_name
      raise Bud::CompileError, "#{local_name} is already taken"
    else
      src = %Q{
        def #{local_name}
          @#{local_name}
        end
        def #{local_name}=(val)
          raise Bud::Error, "type error: expecting an instance of #{mod}" unless val.kind_of? #{mod}
          @#{local_name} = val
        end
      }
      self.class_eval src
    end

    import_tbl = self.bud_import_table
    import_tbl[local_name] = mod
  end

  def bud_import_table() #:nodoc: all
    @bud_import_tbl ||= {}
    @bud_import_tbl
  end


  # the block of Bloom collection declarations.  one per module.
  def state(&block)
    meth_name = Module.make_state_meth_name(self)
    define_method(meth_name, &block)
  end

  def build(spec, &block)
    builder, local_name = spec.first
    meth_name = "__build__#{local_name}"
    define_method(meth_name, &block)

    if self.method_defined? local_name
      raise Bud::CompileError, "#{local_name} is already taken"
    else
      src = %Q{
        def #{local_name}
          @#{local_name}
        end
        def #{local_name}=(val)
          @#{local_name} = val
        end
      }
      self.class_eval src
    end

    unless self.respond_to? :__build_blocks__
      def self.__build_blocks__
        @__build_blocks__ ||= {}
        @__build_blocks__
      end
    end
    __build_blocks__[meth_name] = {:block => block, :builder => builder, :local_name => local_name}
  end

  def sugar(spec, &block)
    builder, local_name = spec.first
    meth_name = "__sugar__#{local_name}"
    define_method(meth_name, &block)

    if self.method_defined? local_name
      raise Bud::CompileError, "#{local_name} is already taken"
    else
      src = %Q{
        def #{local_name}
          @#{local_name}
        end
        def #{local_name}=(val)
          @#{local_name} = val
        end
      }
      self.class_eval src
    end

    unless self.respond_to? :__sugar_blocks__
      def self.__sugar_blocks__
        @__sugar_blocks__ ||= {}
        @__sugar_blocks__
      end
    end
    __sugar_blocks__[meth_name] = {:block => block, :builder => builder, :local_name => local_name}
  end

  # a ruby block to be run before timestep 1.  one per module.
  def bootstrap(&block)
    meth_name = "__bootstrap__#{Module.get_class_name(self)}".to_sym
    define_method(meth_name, &block)
  end

  def bloom_dynamic(meth_name, stmt)
    parser = RubyParser.for_current_ruby
    ast = parser.parse stmt
    bloom_finish meth_name, ast do
    end
  end

  # bloom statements to be registered with Bud runtime.  optional +block_name+ 
  # allows for multiple bloom blocks per module and method overriding
  def bloom(block_name=nil, &block)
    # If no block name was specified, generate a unique name
    if block_name.nil?
      @block_id ||= 0
      block_name = "#{Module.get_class_name(self)}__#{@block_id}".to_sym
      @block_id += 1
    else
      unless block_name.class <= Symbol
        raise Bud::CompileError, "block name must be a symbol: #{block_name}"
      end
    end

    # Note that we don't encode the module name ("self") into the name of the
    # method. This allows named blocks to be overridden (via inheritance or
    # mixin) in the same way as normal Ruby methods.
    meth_name = "__bloom__#{block_name}"

    # Don't allow duplicate named bloom blocks to be defined within a single
    # module; this indicates a likely programmer error.
    if instance_methods(false).include?(meth_name) ||
       instance_methods(false).include?(meth_name.to_sym)
      raise Bud::CompileError, "duplicate block name: '#{block_name}' in #{self}"
    end
    ast = Source.read_block(caller[0]) # pass in caller's location via backtrace

    bloom_finish(meth_name, ast, &block)
  end

  private
  def bloom_finish(meth_name, ast, &block)
    # ast corresponds only to the statements of the block. Wrap it in a method
    # definition for backward compatibility for now.

    # If the block contained multiple statements, the AST will have a top-level
    # :block node. Since ruby_parser ASTs for method definitions don't contain
    # such a node, remove it.
    if ast.nil?
      ast = []
    elsif ast.sexp_type == :block
      ast = ast.sexp_body
    else
      ast = [ast]
    end
    ast = s(:defn, meth_name.to_sym, s(:args), *ast)
    unless self.respond_to? :__bloom_asts__
      def self.__bloom_asts__
        @__bloom_asts__ ||= {}
        @__bloom_asts__
      end
    end
    __bloom_asts__[meth_name] = ast
    define_method(meth_name.to_sym, &block)
  end

  # Return a string with a version of the class name appropriate for embedding
  # into a method name. Annoyingly, if you define class X nested inside
  # class/module Y, X's class name is the string "Y::X". We don't want to define
  # method names with semicolons in them, so just return "X" instead.
  private
  def self.get_class_name(klass)
    (klass.name.nil? or klass.name == "") \
      ? "Anon#{klass.object_id}" \
      : klass.name.split("::").last
  end

  # State method blocks are named using an auto-incrementing counter. This is to
  # ensure that we can rediscover the possible dependencies between these blocks
  # after module import (see Bud#call_state_methods).
  def self.make_state_meth_name(klass)
    @state_meth_id ||= 0
    r = "__state#{@state_meth_id}__#{Module.get_class_name(klass)}".to_sym
    @state_meth_id += 1
    return r
  end
end


module Enumerable
  public
  # We rewrite "map" calls in Bloom blocks to invoke the "pro" method
  # instead. This is fine when applied to a BudCollection; when applied to a
  # normal Enumerable, just treat pro as an alias for map.
  def pro(&blk)
    map(&blk)
  end
end
