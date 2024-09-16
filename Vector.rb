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

  #--::::::::::::::::::::::::::::::::::::::::
  #------------------------------------------
  #++
  ## ensure a Vector. (for class)
  ## _aValue_:: a Vector or [_x_, _y_]
  ## *return* :: a Vector
  def self.sureVector(_aValue) ;
    return self.sureGeoObject(_aValue) ;
  end
  
  #------------------------------------------
  #++
  ## ensure a Vector. (for instance)
  ## _aValue_:: a Vector or [_x_, _y_]
  ## *return* :: a Vector
  def sureVector(_aValue) ;
    return sureGeoObject(_aValue) ;
  end

  #------------------------------------------
  #++
  ## convert to Array
  ## *return* :: an Array [x,y,z]
  def to_a()
    return [@x, @y, @z] ;
  end

  #------------------------------------------
  #++
  ## convert to Hash
  ## *return* :: a Hash { x: xVal, y: yVal, z: zVal }
  def to_h()
    return { x: @x, y: @y, z: @z } ;
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
  ## _aVector_:: amount of increment. a Vector or an Array.
  def inc(_aVector)
    _aVector = sureVector(_aVector) ;
    @x += _aVector.x ;
    @y += _aVector.y ;
    @z += _aVector.z ;
    
    return self ;
  end

  #------------------------------------------
  #++
  ## increment.
  ## _aVector_:: amount of decrement. a Vector or an Array
  def dec(_aVector)
    _aVector = sureVector(_aVector) ;
    @x -= _aVector.x ;
    @y -= _aVector.y ;
    @z -= _aVector.z ;
    
    return self ;
  end

  #------------------------------------------
  #++
  ## amplify
  ## _factor_:: amount of amplify. a Numeric
  def amp(_factor)
    @x *= _factor ;
    @y *= _factor ;
    @z *= _factor ;
    
    return self ;
  end

  #--////////////////////////////////////////////////////////////
  ## arithmetic operators: +, -, *, /
  #--------------------------------------------------------------
  #++
  ## plus
  ## _aVector_:: amount of increment. a Vector or an Array.
  def +(_aVector)
    return self.dup().inc(_aVector) ;
  end

  #------------------------------------------
  #++
  ## minus
  ## _aVector_:: amount of decrement. a Vector or an Array
  def -(_aVector)
    return self.dup().dec(_aVector) ;
  end
  
  #------------------------------------------
  #++
  ## minus (single arity operator)
  ## _aVector_:: amount of decrement. a Vector or an Array
  def -@()
    return self.dup().amp(-1) ;
  end

  #------------------------------------------
  #++
  ## multiply by scalar
  ## _factor_:: amount of amplify. a Numeric
  def *(_factor)
    return self.dup().amp(_factor) ;
  end
  
  #------------------------------------------
  #++
  ## divide by scalar
  ## _factor_:: amount of divide. a Numeric
  def /(_factor)
    return self.dup().amp(1.0/_factor) ;
  end
  
  #--////////////////////////////////////////////////////////////
  ## geometric operator
  #--------------------------------------------------------------
  #++
  ## length
  ## *return*:: scalar
  def length()
    return Math.sqrt(self.sqLength()) ;
  end

  #------------------------------------------
  #++
  ## norm
  ## *return*:: scalar
  def norm()
    return length() ;
  end

  #------------------------------------------
  #++
  ## square length
  ## *return*:: scalar
  def sqLength()
    return (@x * @x + @y * @y + @z * @z) ;
  end

  #--------------------------------------------------------------
  #++
  ## unit vector
  ## _unit_:: unit length. (default = 1.0) ;
  ## *return*:: an unit Vector.
  def unit(_unit = 1.0) ;
    return self / (self.length()/_unit) ;
  end

  #--------------------------------------------------------------
  #++
  ## inner product
  ## _other_:: a Vector
  ## *return*:: inner product in scalar.
  def innerProd(_other)
    return (self.x * _other.x + self.y * _other.y + self.z * _other.z) ;
  end

  #--------------------------------------------------------------
  #++
  ## cosine of angle of two vector
  ## _other_:: a Vector
  ## *return*:: cosine value
  def cos(_other)
    return (innerProd(_other).to_f / (self.length() * _other.length())) ;
  end

  #------------------------------------------
  #++
  ## arccosine of angle of two vector
  ## _other_:: a Vector
  ## *return*:: arccosine value in radiun
  def acos(_other)
    return Math::acos(self.cos(_other)) ;
  end

  #------------------------------------------
  #++
  ## angle with other
  ## _other_:: a Vector
  ## *return*:: arccosine value in radian
  def angle(_other)
    return self.acos(_other) ;
  end

  #------------------------------------------
  #++
  ## angle with other in degree
  ## _other_:: a Vector
  ## *return*:: arccosine value in degree
  def angleInDeg(_other)
    return rad2deg(self.angle(_other)) ;
  end

  #------------------------------------------
  #++
  ## rotate around X asis
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector.
  def rotateByX(_angle)
    return dup().rotateByX!(_angle) ;
  end

  #----------------------
  #++
  ## rotate around X asis (modify self)
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector.(self)
  def rotateByX!(_angle)
    _c = Math::cos(_angle) ;
    _s = Math::sin(_angle) ;
    set(@x,
        _c * @y - _s * @z,
        _s * @y + _c * @z) ;
    return self ;
  end

  #----------------------
  #++
  ## rotate around X asis in degree
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector.
  def rotateByXInDeg(_angle)
    return dup().rotateByXInDeg!(_angle) ;
  end

  #----------------------
  #++
  ## rotate around X asis in degree (modify self)
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector.(self)
  def rotateByXInDeg!(_angle)
    return rotateByX!(deg2rad(_angle)) ;
  end
  
  
  #------------------------------------------
  #++
  ## rotate around Y asis
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector 
  def rotateByY(_angle)
    return dup().rotateByY!(_angle) ;
  end

  #----------------------
  #++
  ## rotate around Y asis (modify self)
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector
  def rotateByY!(_angle)
    _c = Math::cos(_angle) ;
    _s = Math::sin(_angle) ;
    set(_s * @z + _c * @x,
        @y,
        _c * @z - _s * @x) ;
    return self ;
  end
  
  #----------------------
  #++
  ## rotate around Y asis in degree
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector.
  def rotateByYInDeg(_angle)
    return dup().rotateByYInDeg!(_angle) ;
  end

  #----------------------
  #++
  ## rotate around Y asis in degree (modify self)
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector.(self)
  def rotateByYInDeg!(_angle)
    return rotateByY!(deg2rad(_angle)) ;
  end
  
  
  #------------------------------------------
  #++
  ## rotate around Z asis
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector 
  def rotateByZ(_angle)
    return dup().rotateByZ!(_angle) ;
  end

  #----------------------
  #++
  ## rotate around Z asis (modify self)
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector
  def rotateByZ!(_angle)
    _c = Math::cos(_angle) ;
    _s = Math::sin(_angle) ;
    set(_c * @x - _s * @y,
        _s * @x + _c * @y,
        @z) ;
    return self ;
  end

  #----------------------
  #++
  ## rotate around Z asis in degree
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector.
  def rotateByZInDeg(_angle)
    return dup().rotateByZInDeg!(_angle) ;
  end

  #----------------------
  #++
  ## rotate around Z asis in degree (modify self)
  ## _angle_:: angle to rotate
  ## *return*:: rotated Vector.(self)
  def rotateByZInDeg!(_angle)
    return rotateByZ!(deg2rad(_angle)) ;
  end

  #--////////////////////////////////////////////////////////////
  # bbox and min/max XYZ
  #--------------------------------------------------------------
  #++
  ## minX
  def minX()
    return @x ;
  end

  #------------------------------------------
  #++
  ## maxX
  def maxX()
    return @x ;
  end

  #--------------------------------------------------------------
  #++
  ## minY
  def minY()
    return @y ;
  end

  #------------------------------------------
  #++
  ## maxY
  def maxY()
    return @y ;
  end

  #--------------------------------------------------------------
  #++
  ## minZ
  def minZ()
    return @z ;
  end

  #------------------------------------------
  #++
  ## maxZ
  def maxZ()
    return @z ;
  end
  

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class Vector
#--======================================================================
end ; end # module Geo3D ; module Itk

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

    #----------------------------------------------------
    #++
    ## add, etc.
    def test_c
      v = Vector.new(1,2,3) ;
      p [:init, v] ;
      v.inc([4,5,6]) ;
      p [:inc, v] ;
      v.dec([7,6,5]) ;
      p [:dec, v] ;
      v.amp(10) ;
      p [:amp, v] ;

      p [:+, v + [5,4,3], v] ;
      p [:-, v - [5,4,3], v] ;
      p [:-@, -v, v] ;
      p [:*, v * 100, v] ;
      p [:/, v / 100, v] ;
    end

    #----------------------------------------------------
    #++
    ## geometric operators
    def test_d
      v0 = Vector.new(2,4,4) ;
      p [:v0, v0] ;
      p [:length, v0.length()] ;
      p [:unit, v0.unit()] ;
      p [:unit2, v0.unit(2)] ;

      v1 = Vector.new(1,2,3) ;
      p [:v1, v1] ;
      p [:innerProd, v0.innerProd(v1)] ;
      p [:cos, v0.cos(v1)] ;
      p [:acos, v0.acos(v1)] ;
      p [:angle, v0.angle(v1)] ;
      p [:angleDeg, v0.angleInDeg(v1)] ;
    end

    #----------------------------------------------------
    #++
    ## rotate
    def test_e
      v = Vector.new(1,2,3) ;
      p [:v, v] ;
      p [:rotateByX, v.rotateByX(PI / 3)] ;
      p [:rotateByY, v.rotateByY(PI / 3)] ;
      p [:rotateByZ, v.rotateByZ(PI / 3)] ;
      p [:rotateByXInDeg, v.rotateByXInDeg(60)] ;
      p [:rotateByYInDeg, v.rotateByYInDeg(60)] ;
      p [:rotateByZInDeg, v.rotateByZInDeg(60)] ;
    end
    
    
    
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
