#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = class Vector
## Author:: Itsuki Noda
## Version:: 0.0 2024/09/07 I.Noda
##
## === History
## * [2024/09/07]: Create This File.
## * [YYYY/MM/DD]: add more
## == Usage
## * ...

def $LOAD_PATH.addIfNeed(path, lastP = false)
  existP = self.index{|item| File.identical?(File.expand_path(path),
                                             File.expand_path(item))} ;
  if(!existP) then
    if(lastP) then
      self.push(path) ;
    else
      self.unshift(path) ;
    end
  end
end

$LOAD_PATH.addIfNeed("~/lib/ruby");
$LOAD_PATH.addIfNeed(File.dirname(__FILE__));

require 'optparse' ;
require 'pp' ;

require 'GeoObject.rb' ;

module Itk ; module Geo3D ;
#--======================================================================
#++
## Vector class
class Vector < GeoObject
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## default values for WithConfParam#getConf(_key_).
#  DefaultConf = { :bar => :baz } ;
  ## the list of attributes that are initialized by getConf().
#  DirectConfAttrList = [:bar] ;
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## X
  attr :x, true ;
  ## Y
  attr :y, true ;
  ## Z
  attr :z, true ;

  #--------------------------------------------------------------
  #++
  ## initialize
  ## _v_:: about argument baz.
  def initialize(*_v)
    if(_v.length == 0) then
      set(0.0, 0.0, 0.0) ;
    else
      set(*_v) ;
    end
  end

  #--::::::::::::::::::::::::::::::::::::::::
  #------------------------------------------
  #++
  ## ensure a Vector.
  ## _aValue_:: a Vector or [_x_, _y_]
  ## *return* :: a Vector
  def self.sureGeoObject(_aValue)
    case _aValue ;
    when Vector ;
      return _aValue ;
    when Array ;
      return Vector.new(_aValue) ;
    else
      raise ("#{self}::sureGeoObject() does not support conversion from : " +
             _aValue.inspect) ;
    end
  end

  #------------------------------------------
  #++
  ## ensure a Vector.
  ## _aValue_:: a Vector or [_x_, _y_]
  ## *return* :: a Vector
  def sureVector(_aValue) ;
    return sureGeoObject(_aValue) ;
  end

  #--------------------------------------------------------------
  #++
  ## set value
  ## two format:
  ##   set(_x_,_y_,_z_)
  ##   set(_v)
  ## _x_:: X value
  ## _y_:: Y value
  ## _z_:: Z value
  ## _v_:: Vector or Array
  def set(*_args)
    case (_args.length)
    when 3 ;
      (@x, @y, @z) = _args ;
    when 1 ;
      _value = _args[0] ;
      case _value ;
      when Vector ;
        @x = _value.x ;
        @y = _value.y ;
        @z = _value.z ;
      when Array ;
        (@x, @y, @z) = _value ;
      else
        raise ("In Vector##set(value), value should be Vector or Array:value=" + _value.inspect) ;
      end
    else ;
      raise ("Vector##set(value) should have 1 or 3 args: " + _args.inspect) ;
    end
    
    return self ;
  end

  #--////////////////////////////////////////////////////////////
  ## inc / dec / amp : modify self.
  #--------------------------------------------------------------
  #++
  ## increment.
  ## _aVector_:: amount of increment.
  def inc(_aVector)
    
  end
  
  #--------------------------------------------------------------
  #++
  ## description of method foo
  ## _bar_:: about argument bar
  ## *return*:: about return value
#  def foo(bar, &block) # :yield: arg1, arg2
#  end

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class Vector
end ; end ;

########################################################################
########################################################################
########################################################################
if($0 == __FILE__) then

  require 'test/unit'

  include Itk::Geo3D ;

  #--============================================================
  #++
  # :nodoc:
  ## unit test for this file.
  class TC_Foo < Test::Unit::TestCase
    #--::::::::::::::::::::::::::::::::::::::::::::::::::
    #++
    ## desc. for TestData
    TestData = nil ;

    #----------------------------------------------------
    #++
    ## show separator and title of the test.
    def setup
#      puts ('*' * 5) + ' ' + [:run, name].inspect + ' ' + ('*' * 5) ;
      name = "#{(@method_name||@__name__)}(#{self.class.name})" ;
      puts ('*' * 5) + ' ' + [:run, name].inspect + ' ' + ('*' * 5) ;
      super
    end

    #----------------------------------------------------
    #++
    ## let
    def test_a
      v = Vector.new() ;
      p [:v, :init, v] ;
      v.set(1,2,3) ;
      p [:v, :set123, v] ;
      
      u = Vector.new(5,6,7) ;
      p [:u, :init, u] ;
      v.set(u) ;
      p [:v, :setU, v] ;
      v.set([9,8,7]) ;
      p [:v, :setA, v] ;

      v.set([4,3]) ;
      p [:v, :setA2, v] ;

      begin
        v.set(4,3) ;
        p [:v, :setA3, v] ;
      rescue => ex
        pp [:raise, ex] ;
      end
    end

    #----------------------------------------------------
    #++
    ## sureGeoObject
    def test_b
      v = Vector.new() ;
      [Vector.new(1,2,3), [4,5,6], 7, nil].each{|aValue|
        begin
          p [:sureGeoObject, aValue, Vector.sureGeoObject(aValue)] ;
          p [:sureVector, aValue, v.sureVector(aValue)] ;
        rescue => ex
          pp [:rescue, ex.to_s, ex.backtrace[0...5]] ;
        end
      }
    end
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
