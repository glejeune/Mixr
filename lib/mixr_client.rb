# Copyright (c) 2008 Gregoire Lejeune
#  
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#   
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#    
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'socket'

class MixrError < StandardError; end

class MixrClient
  
  def initialize( h = 'localhost', p = 9900 )
    @host = h
    @port = p
  end
  
  private
  def action( c )
    socket = TCPSocket.new( @host, @port )
    socket.write( c )
    r = socket.read
    socket.close
    r
  end
  
  def id
    @id
  end
  
  public
  
  #   hsh.clear -> hsh
  # 
  # Removes all key-value pairs from _hsh_.
  def clear
    eval(action( "CLEAR@" ))
    self
  end
  
  #   hsh.keys    => array
  # 
  # Returns a new array populated with the keys from this hash.
  def keys
    eval(action( "KEYS@" ))
  end
  
  #   hsh.values    => array
  #
  # Returns a new array populated with the values from _hsh_.
  def values
    eval(action( "VALUES@" ))
  end
  
  #   hsh.each_value {| value | block } -> hsh
  #
  # Calls _block_ once for each key in _hsh_, passing the value as a
  # parameter.
  def each_value( &b )
    values.each do |v|
      yield( v )
    end
  end
  
  #   hsh.each_key {| key | block } -> hsh
  # 
  # Calls _block_ once for each key in _hsh_, passing the key as a
  # parameter.
  def each_key( &b )
    keys.each do |k|
      yield( k )
    end
  end
  
  #   hsh.empty?    => true or false
  # 
  # Returns +true+ if _hsh_ contains no key-value pairs.
  def empty?
    keys.size == 0
  end
         
  #   hsh.each {| key, value | block } -> hsh
  # 
  # Calls _block_ once for each key in _hsh_, passing the key and value
  # to the block as a two-element array. Because of the assignment
  # semantics of block parameters, these elements will be split out if
  # the block has two formal parameters. Also see +Hash.each_pair+,
  # which will be marginally more efficient for blocks with two
  # parameters.
  def each( &b )
    keys.each do |k|
      yield(k, self[k])
    end
    self
  end
  
  #   hsh.delete(key)                   => value
  #   hsh.delete(key) {|key| block }    => value
  # 
  # Deletes and returns a key-value pair from _hsh_ whose key is equal
  # to _key_. If the key is not found, returns the _default value_. If
  # the optional code block is given and the key is not found, pass in
  # the key and return the result of _block_.     
  def delete( k )
    begin
      r = eval(action( "DELETE@#{k}" ))
    rescue SyntaxError
      r = nil
    end
    if block_given? and r.nil?
      yield( k ) 
    else
      r
    end
  end
  
  #   hsh[key] = value        => value
  #   hsh.store(key, value)   => value
  # 
  # Element Assignment---Associates the value given by _value_ with the
  # key given by _key_. _key_ should not have its value changed while
  # it is in use as a key.
  def []=( k, v )
    unless eval(action( "SET@#{k}|#{v}" ))
      raise MixrError, "Can't set #{k} with value #{v}!"
    end
  end
  alias :store :[]=
  
  #   hsh[key]    =>  value
  #
  # Element Reference---Retrieves the _value_ object corresponding to
  # the _key_ object. If not found, returns the a default value
  def []( k )
    begin
      eval(action( "GET@#{k}" ))
    rescue SyntaxError
      nil
    end
  end
  
  #   hsh.fetch(key [, default] )       => obj
  #   hsh.fetch(key) {| key | block }   => obj
  # 
  # Returns a value from the hash for the given key. If the key can't
  # be found, there are several options: With no other arguments, it
  # will raise an +IndexError+ exception; if _default_ is given, then
  # that will be returned; if the optional code block is specified,
  # then that will be run and its result returned.
  def fetch( k, d = nil )
    r = self[k] || d
    if block_given? and r.nil?
      r = yield( k )
    end
    r
  end
  
  #   hsh.length    =>  fixnum
  #   hsh.size      =>  fixnum
  # 
  # Returns the number of key-value pairs in the hash.
  def length
    keys.size
  end
  alias :size :length
  
  #   hsh.has_key?(key)    => true or false
  #   hsh.include?(key)    => true or false
  #   hsh.key?(key)        => true or false
  #   hsh.member?(key)     => true or false
  # 
  # Returns +true+ if the given key is present in _hsh_.
  def has_key?( k )
    keys.include?( k )
  end
  alias :include? :has_key?
  alias :key? :has_key?
  alias :member? :has_key?
  
  #   hsh.has_value?(value)    => true or false
  #   hsh.value?(value)        => true or false
  #
  # Returns +true+ if the given value is present for some key in _hsh_.
  def has_value?( v )
    values.include?( v )
  end
  alias :value? :has_value?
  
  def to_hash
    h = {}
    self.each do |k, v|
      h[k] = v
    end
    h
  end
  
  # Do it !
  def method_missing( id, *args ) 
    to_hash.send( id.id2name, *args )
  end
end
