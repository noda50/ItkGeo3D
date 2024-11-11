#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = 3D Circle and Ellipse class
## Author:: Itsuki Noda
## Version:: 0.0 2024/11/11 I.Noda
##
## === History
## * [2024/11/11]: Create This File.
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

require 'Point.rb' ;
require 'Vector.rb' ;
require 'Ring.rb' ;

module Itk ; module Geo3D ;
#--======================================================================
#++
## description of class Foo.
class Ellipse < GeoObject
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## default values for WithConfParam#getConf(_key_).

  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## center point
  attr :center, true ;
  ## major axis
  attr :axisMajor, true ;
  ## minor axis
  attr :axisMinor, true ;
  ## axis of rotation
  attr :pivot, true ;
  
  #--------------------------------------------------------------
  #++
  ## initialize.
  ## _center_:: center Point
  ## _axisMajor_:: major axis Vector
  ## _axisMinor_:: minor axis Vector
  ## _orthgonalP_:: a flag to force _axisMinor_ orthogonal to _aixsMajor_.
  def initialize(_center, _axisMajor, _axisMinor, _orthogonalP = true)
    @center = Point.sureGeoObject(_center) ;
    @axisMajor = Vector.sureGeoObject(_axisMajor) ;
    
    @axisMinor = Vector.sureGeoObject(_axisMinor) ;
    @axisMinor = @axisMajor.orthogonalize(@axisMinor) if(_orthogonalP) ;

    @pivot = @axisMajor.outerProd(@axisMinor).unit() ;
  end

  #--------------------------------
  #++
  ## pivot
  def pivot()
    @pivot = @axisMajor.outerProd(@axisMinor).unit() if(!@pivot) ;

    return @pivot ;
  end

  #--========================================
  #------------------------------------------
  #++
  ## new Circle instance by center, pivot, and radius.
  ## _center_:: center of the circle.
  ## _radius_:: radius of the circle.
  ## _pivot_:: pivot (rotating axis) Vector.
  ## _axisMajor_:: the major axis. can be nil.
  def self.newCircle(_center, _radius, _pivot, _axisMajor = nil)
    _pivot = Vector.sureGeoObject(_pivot) ;
    
    if(_axisMajor.nil?) then
      _axisMajor = Vector.new(1.0,0.0,0.0) ;
      if(isAlmostZero(_pivot.angle(_axisMajor))) then
        _axisMajor = Vector.new(0.0,1.0,0.0) ;
      end
    end
    _axisMajor = _pivot.orthogonalize(_axisMajor).unit(_radius) ;

    _axisMinor = _pivot.outerProd(_axisMajor).unit(_radius) ;

    _circle = self.new(_center, _axisMajor, _axisMinor) ;
    _circle.pivot = _pivot ;

    return _circle ;
  end
  

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## 円周上の点
  def arcPoint(_angle)
    return (@center + @axisMajor.ellipticMixtureWith(@axisMinor, _angle)) ;
  end

  #------------------------------------------
  #++
  ## 円周上の点
  def arcPointInDeg(_angle)
    return arcPoint(deg2rad(_angle)) ;
  end

  #------------------------------------------
  #++
  ## 円周上の点で繰り返し
  def eachArcPoint(_delta = 0.1, _from = 0.0, _until = DoublePI, &_block)
    _angle = _from ;
    while(_angle < _until)
      _point = self.arcPoint(_angle) ;
      _block.call(_point, _angle, self) ;
      _angle += _delta ;
    end
  end

  #------------------------------------------
  #++
  ## 円周上の点で繰り返し
  def eachArcPointInDeg(_delta = 5.0, _from = 0.0, _until = 360.0, &_block)
    eachArcPoint(deg2rad(_delta), deg2rad(_from), deg2rad(_until), &_block) ;
  end

  #------------------------------------------
  #++
  ## 円周上の点で繰り返し
  def eachArcPointByN(_n, _from = 0.0, _until = DoublePI, &_block)
    _delta = (_until - _from)/_n ;
    eachArcPoint(_delta, _from, _until, &_block) ;
  end

  #------------------------------------------
  #++
  ## 円周上の点で繰り返し
  def eachArcPointByNInDeg(_n, _from = 0.0, _until = 360.0, &_block)
    _delta = (_until - _from)/_n ;
    eachArcPointInDeg(_delta, _from, _until, &_block) ;
  end

  #------------------------------------------
  #++
  ## 円周上の点から Ring を作る
  def circumferenceRingByN(_n)
    _pointList = [] ;
    self.eachArcPointByN(_n){|_point|
      _pointList.push(_point) ;
    }

    _ring = Ring.new(_pointList) ;

    return _ring ;
  end

  #------------------------------------------
  #++
  ## Ellipse を描画
  def draw(_gplot, _label, _n = 100, _styleTable = { w: "l"})
    _styleTable.each{|_category, _style|
      _gplot.dm3pSetStyle(_label, _category, _style) ;
    }
    self.circumferenceRingByN(_n).draw(_gplot, _label) ;
  end
  
  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class Ellipse
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
    ## 
    def test_a
      circle0 = Ellipse.newCircle([1,1,1], 1.5, [1,1,-1]) ;
      circle1 = Ellipse.newCircle([1,1,1], 2.3, [1,1,-1]) ;
      circle2 = Ellipse.newCircle([1,0,1], 1.2, [1,-1,1]) ;


      n = 30 ;
      gconf = { xlabel: "X", ylabel: "Y", zlabel: "Z"} ;
      Gnuplot::directMulti3dPlot([:circle0, :circle1, :circle2], gconf){|gplot|
        circle0.draw(gplot, :circle0, n, { w: "l", lw: 1}) ;
        circle1.draw(gplot, :circle1, n) ;
        circle2.draw(gplot, :circle2, n) ;
      }
      
    end


  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
