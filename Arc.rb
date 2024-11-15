#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = 3D Arc class. a sector shape.
## Author:: Itsuki Noda
## Version:: 0.0 2024/11/15 I.Noda
##
## === History
## * [2024/11/15]: Create This File.
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

#$LOAD_PATH.addIfNeed("~/lib/ruby");
$LOAD_PATH.addIfNeed(File.dirname(__FILE__));

require 'pp' ;

require 'Ellipse.rb' ;

module Itk ; module Geo3D ;
#--======================================================================
#++
## description of class Foo.
class Arc < Ellipse
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## Ring class
  DrawShapeClass = LineString ;

  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## start angle.
  attr :angleFrom, true ;
  ## end angle.
  attr :angleTo, true ;
  
  #--------------------------------------------------------------
  #++
  ## initialize.
  ## _center_:: center Point
  ## _axisMajor_:: major axis Vector
  ## _axisMinor_:: minor axis Vector
  ## _angleFrom_:: start angle
  ## _angleTo_:: end angle
  ## _circleP_:: force to be a circle arc.
  ## _orthogonalP_:: a flag to force _axisMinor_ orthogonal to _aixsMajor_.
  def initialize(_center, _axisMajor, _axisMinor,
                 _angleFrom, _angleTo,
                 _circleP = true, _orthogonalP = true)
    _axisMajor = Vector.sureGeoObject(_axisMajor) ;
    if(_circleP) then
      _axisMinor = Vector.sureGeoObject(_axisMinor).unit(_axisMajor.norm()) ;
    end
    super(_center, _axisMajor, _axisMinor, _orthogonalP) ;
    
    @angleFrom = _angleFrom ;
    @angleTo = _angleTo ;
  end

  #--========================================
  #------------------------------------------
  #++
  ## new Arc by from axis and to axis
  ## _center_:: center of the circle.
  ## _axisFrom_:: from axis
  ## _axisTo_:: to axis
  ## _angleTo_:: if specified, use it as @angleTo.
  ## _circleP_:: form circle.
  def self.newByAxes(_center, _axisFrom, _axisTo,
                     _angleTo = nil,
                     _circleP = true)

    _axisFrom = Vector.sureGeoObject(_axisFrom) ;
    _axisTo = Vector.sureGeoObject(_axisTo) ;

    _angleTo = (_angleTo || _axisFrom.angle(_axisTo)) ;

    _arc = self.new(_center, _axisFrom, _axisTo,
                    0.0, _angleTo, _circleP, true) ;

    return _arc ;
  end
  

  #--////////////////////////////////////////////////////////////
  #------------------------------------------
  #++
  ## 円周上の点で繰り返し
  def eachArcPoint(_delta = 0.1, _from = @angleFrom,
                   _until = @angleTo, &_block)
    super(_delta, _from, _until, &_block) ;
  end

  #------------------------------------------
  #++
  ## 円周上の点で繰り返し
  def eachArcPointByN(_n, _from = @angleFrom, _until = @angleTo, &_block)
    super(_n, _from, _until, &_block) ;
  end

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## 垂線の足(近い方)のある位置の @axisMajor からの角度(単位：radian)を求める。
  ## ただし、@axisMajor と @axisMinor が同じ長さで直交していると仮定。
  ## （つまり楕円でなく、円）
  ## _point_:: 垂線を下ろす点。
  ## _extendP_:: [@angleFrom, @angleTo] に限定するかどうか。
  ## *return*:: 角度 in radian.
  def footPointAngleFrom(_point, _extendP = false)
    _angle = super(_point) ;

    if(!isAngleInOrder(@angleFrom, _angle, @angleTo)) then
      _pointFrom = arcPoint(@angleFrom) ;
      _pointTo = arcPoint(@angleTo) ;
      if(_point.distanceToPoint(_pointFrom) >
         _point.distanceToPoint(_pointTo)) then
        return @angleTo ;
      else
        return @angleFrom ;
      end
    else
      return _angle ;
    end
  end

  #------------------------------------------
  #++
  ## 線分からの垂線の足の点
  ## _geoObject_:: 垂線を下ろす線分。
  ## *return*:: [円弧上の点、線上の点]
  def closestPointPairFrom(_geoObject)
    case(_geoObject)
    when Point ;
      _foot = footPointFrom(_geoObject) ;
      return [_foot, _geoObject] ;
    when LineSegment ;
      return closestPointPairFromLineSegment(_geoObject) ;
    when Ellipse ;
      return closestPointPairFromEllipse(_geoObject) ;
    else
      raise ("closestPointPairFrom() does not support for this class: " +
             _geoObject.inspect) ;
    end
  end
  
  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class Arc
#--======================================================================
end ; end # module Geo3D ; module Itk

########################################################################
########################################################################
########################################################################
if($0 == __FILE__) then

  require 'test/unit'
  require 'gnuplot.rb' ;

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
    ##  new
    def test_a
      arc = Arc.newByAxes([1,0,0], [0,8,0], [0,0,1]) ;
      
      point0 = Point.new([-1,-1,-1]) ;
      pair0 = arc.closestPointPairFrom(point0) ;
      gap0 = LineSegment.new(*pair0) ;

      point1 = Point.new([-1,-1,3]) ;
      pair1 = arc.closestPointPairFrom(point1) ;
      gap1 = LineSegment.new(*pair1) ;

      point2 = Point.new([1,1,3]) ;
      pair2 = arc.closestPointPairFrom(point2) ;
      gap2 = LineSegment.new(*pair2) ;

      arc3 = Arc.newByAxes([-2,8,2], [-6, 0, -6], [-1,-1,-1], PI) ;
      pair3 = arc.closestPointPairFrom(arc3) ;
      gap3 = LineSegment.new(*pair3) ;
      

      gconf = { xlabel: "X", ylabel: "Y", zlabel: "Z",
                xrange: [-11,11], yrange: [-11,11], zrange: [-11,11],
              } ;
      Gnuplot::directMulti3dPlot([:arc, :gap0, :gap1, :gap2,
                                  :arc3, :gap3],
                                 gconf){|gplot|
        arc.draw(gplot, :arc) ;
        gap0.draw(gplot, :gap0) ;
        gap1.draw(gplot, :gap1) ;
        gap2.draw(gplot, :gap2) ;
        arc3.draw(gplot, :arc3) ;
        gap3.draw(gplot, :gap3) ;
      }
      
    end


  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
