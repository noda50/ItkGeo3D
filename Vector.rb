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

$LOAD_PATH.addIfNeed(File.dirname(__FILE__));

require 'optparse' ;
require 'pp' ;

require 'GeoObject.rb' ;
require 'Quaternion.rb' ;

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
  ## _aValue_:: a Vector or [_x_, _y_, _z_]
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
  ## duplicate
  ## _deepP_:: deep copy?
  ## *return* :: a Vector
  def dup(_deepP = false)
    return self.clone() ;
  end

  #--::::::::::::::::::::::::::::::::::::::::
  #------------------------------------------
  #++
  ## ensure a Vector. (for class)
  ## _aValue_:: a Vector or [_x_, _y_, _z_]
  ## *return* :: a Vector
  def self.sureVector(_aValue) ;
    return self.sureGeoObject(_aValue) ;
  end
  
  #------------------------------------------
  #++
  ## ensure a Vector. (for instance)
  ## _aValue_:: a Vector or [_x_, _y_, _z_]
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

  #------------------------------------------
  #++
  ## convert to Json
  ## *return* :: a Hash { class: 'Vector', x: xVal, y: yVal, z: zVal }
  def toJson()
    _json = { class: self.class.to_s }.update(to_h()) ;
    return _json ;
  end

  #--========================================
  #------------------------------------------
  #++
  ## new from Json
  ## *return* :: a Vector
  def self.newByJson(_json)
    _vector = self.new(_json[:x], _json[:y], _json[:z]) ;
    return _vector ;
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

  #------------------------------------------
  #++
  ## check same or not
  ## *return*:: true or false
  def isAlmostSame(_other, _eps = EPS)
    return isAlmostZero((self - _other).length(), _eps) ;
  end

  #--------------------------------------------------------------
  #++
  ## unit vector
  ## _unit_:: unit length. (default = 1.0) ;
  ## *return*:: an unit Vector.
  def unit(_unit = 1.0) ;
    if(isAlmostZero(self.length())) then
      raise "can't let zero vector to be unit vector: " + self.inspect ;
    end
    
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
  ## check orthogonal or not.
  ## _other_:: a Vector
  ## *return*:: true if orthogonal
  def isAlmostOrthogonal(_other, _eps = EPS)
    return isAlmostZero(self.innerProd(_other), _eps) ;
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

  #--------------------------------------------------------------
  #++
  ## outer product
  ## _other_:: other Vector
  ## *return*:: outer product as a Vector.
  def outerProd(_other)
    return self.class.new( self.y * _other.z - self.z * _other.y,
                           self.z * _other.x - self.x * _other.z,
                           self.x * _other.y - self.y * _other.x ) ;
  end
  
  #--////////////////////////////////////////////////////////////
  # rotate by Axis
  #--------------------------------------------------------------
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
  #--------------------------------------------------------------
  #++
  ## 四元数による一般の回転
  ## _angle_:: 回転角 (radian)
  ## _axis_:: 回転軸方向ベクトル
  ## _origin_:: 回転原点
  def rotate(_angle, _axis, _origin = Vector.new(0.0,0.0,0.0))
    _offset = self - _origin ;
    _offQuat = Quaternion.new(0.0, _offset.x, _offset.y, _offset.z)
    
    _u = sureVector(_axis).unit() ;
    _cos = Math.cos(_angle/2.0) ;
    _sin = Math.sin(_angle/2.0) ;
    _rotQuat = Quaternion.new(_cos, _u.x * _sin, _u.y * _sin, _u.z * _sin) ;

    _resQuat = (_rotQuat * _offQuat) * _rotQuat.conj() ;
    _newVec = sureVector(_origin) + [_resQuat.i, _resQuat.j, _resQuat.k] ;

    return _newVec ;
  end

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## 直交化。self に対し、与えられたベクトル _other_ を直交するまで回転する。
  ## 計算としては、ベクトル X(=self), Y(=other) に対して、
  ## Y' = Y + alpha (Y-X) とし、 Y' と X が直交するとする。
  ## X Y' = X (Y + alpha (Y-X)) = XY + alpha X(Y-X) = 0
  ## alpha = XY/(X(X-Y))
  ## Y'' = |Y| * Y'.unit
  ## 直交化できない（平行など）場合は、例外を発生する。
  ## _other_:: 回転するベクトル
  def orthogonalize(_other)
    _other = self.sureGeoObject(_other) ;
    _diff = self - _other ;
    _diff = self - (_other * 0.5) if(self.isAlmostOrthogonal(_diff)) ;

    if(self.isAlmostOrthogonal(_diff)) then ## 平行の場合
      raise ("can't orthogonalize parallel Vector: " +
             self.inspect + " // " + _other.inspect) ;
    end
      
    _alpha = self.innerProd(_other) / self.innerProd(_diff) ;
    _orthoDir = _other - _diff * _alpha ;
    _orthoVector = _orthoDir.unit(_other.length()) ;

    return _orthoVector ;
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
  #--------------------------------------------------------------
  #++
  ## 別ベクトルとの混合。
  ## _mixtureVector_ = _frac_ * self + (1 - _frac_) * _other_
  ## _other_:: もう1つのベクトル
  ## _frac_:: 割合
  ## *return*:: 混合ベクトル
  def mixtureWith(_other, _frac)
    _other = self.class.sureGeoObject(_other) ;
    return (self * _frac + _other * (1.0 - _frac)) ;
  end

  #------------------------------------------
  #++
  ## 別ベクトルとの中点。
  ## _other_:: もう1つのベクトル
  ## _frac_:: 割合
  ## *return*:: 混合ベクトル
  def midVectorWith(_other, _frac = 0.5)
    return self.mixtureWith(_other, _frac) ;
  end
  
  #------------------------------------------
  #++
  ## 楕円による混合
  ## _other_:: もう1つのベクトル
  ## _angle_:: 角度
  ## *return*:: 混合ベクトル
  def ellipticMixtureWith(_other, _angle)
    return (self * Math.cos(_angle) + _other * Math.sin(_angle)) ;
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

    #----------------------------------------------------
    #++
    ## rotate by Quaternion
    def test_f
      v = Vector.new(1,2,3) ;
      p [:v, v] ;
      p [:rotateByX0, v.rotate(PI/3, [1, 0, 0], [0,0,0])] ;
      p [:rotateByX0a, v.rotateByX(PI/3)] ;
      p [:rotateByX1, v.rotate(PI/3, [1, 0, 0], [1,1,1])] ;
      p [:rotateByXY0, v.rotate(PI/3, [1, 1, 0], [0,0,0])] ;
      p [:rotateByXYZ0, v.rotate(PI/3, [1, 1, 1], [0,0,0])] ;
    end

    #----------------------------------------------------
    #++
    ## rotate by Quaternion
    def test_g
      u = Vector.new(1,0,0) ;
      v = Vector.new(1,1,1) ;
      w = u.orthogonalize(v) ;

      pp [:vec, u.to_a, v.to_a, w.to_a] ;
      pp [:innerProd, u.innerProd(w)] ;
    end
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
