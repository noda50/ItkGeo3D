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

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## 垂線の足(近い方)のある位置の @axisMajor からの角度(単位：radian)を求める。
  ## ただし、@axisMajor と @axisMinor が同じ長さで直交していると仮定。
  ## （つまり楕円でなく、円）
  ## _point_:: 垂線を下ろす点。
  ## *return*:: 角度 in radian.
  def footPointAngleFrom(_point)
    _axisMajorLine = LineSegment.new(@center, @center + @axisMajor) ;
    _axisMinorLine = LineSegment.new(@center, @center + @axisMinor) ;

    _fracMajor = _axisMajorLine.footPointFractionFrom(_point, true) ;
    _fracMinor = _axisMinorLine.footPointFractionFrom(_point, true) ;

    _angle = Math.atan2(_fracMinor, _fracMajor) ;

    return _angle ;
  end

  #------------------------------------------
  #++
  ## 円弧上の角度
  ## _point_:: 円弧状の点。
  ## *return*:: 角度
  def arcPointAngle(_point)
    return footPointAngleFrom(_point) ;
  end
  
  #------------------------------------------
  #++
  ## 垂線の足の点
  ## _point_:: 垂線を下ろす点。
  ## *return*:: 垂線の足の位置
  def footPointFrom(_point)
    _angle = self.footPointAngleFrom(_point) ;
    _footPoint = self.arcPoint(_angle) ;

    return _footPoint ;
  end

  #------------------------------------------
  #++
  ## 線分からの垂線の足の点
  ## _line_:: 垂線を下ろす線分。
  ## _extendP_:: 線分を延長するかどうか？
  ## *return*:: [円弧上の点、線上の点]
  def closestPointPairFromLineSegment(_line, _extendP = false)
    _arcPointPre = nil ;
    _arcPoint = nil ;
    _linePointPre = nil ;
    _linePoint = _line.u ;
    until(_linePointPre &&
          isAlmostZero(_linePointPre.distanceToPoint(_linePoint)))
      _arcPointPre = _arcPoint ;
      _arcPoint = self.footPointFrom(_linePoint) ;
      
      _linePointPre = _linePoint ;
      _linePoint = _line.footPointFrom(_arcPoint, _extendP) ;
    end

    return [_arcPoint, _linePoint] ;
  end

  #------------------------------------------
  #++
  ## 円弧からの垂線の足の点
  ## _other_:: 垂線を下ろす円。
  ## *return*:: [self上の点、other上の点]
  def closestPointPairFromEllipse(_other)
    _pointPair0 = closestPointPairFromEllipseNaive(_other, 0.0) ;
    _pointPair1 = closestPointPairFromEllipseNaive(_other, PI) ;

    dist0 = _pointPair0[0].distanceToPoint(_pointPair0[1]) ;
    dist1 = _pointPair1[0].distanceToPoint(_pointPair1[1]) ;

    return (dist0 < dist1 ? _pointPair0 : _pointPair1) ;
  end
  
  #------------------------------------------
  #++
  ## 円弧からの垂線の足の点
  ## _other_:: 垂線を下ろす円。
  ## _startAngle_:: 探索を開始する角度。
  ## *return*:: [self上の点、other上の点]
  def closestPointPairFromEllipseNaive(_other, _startAngle = 0.0)
    _selfPointPre = nil ;
    _selfPoint = nil
    _otherPointPre = nil ;
    _otherPoint = _other.arcPoint(_startAngle) ;
    until(_otherPointPre &&
          isAlmostZero(_otherPointPre.distanceToPoint(_otherPoint)))
      _selfPointPre = _selfPoint ;
      _selfPoint = self.footPointFrom(_otherPoint) ;
      
      _otherPointPre = _otherPoint ;
      _otherPoint = _other.footPointFrom(_selfPoint) ;
    end

    return [_selfPoint, _otherPoint] ;
  end

  #--------------------------------------------------------------
  #++
  ## 点までの距離関係情報
  ## _point_:: 対象となる Point
  ## *return*:: [_distance_, _footPoint_, _angle_]
  def distanceInfoToPoint(_point)
    _angle = self.footPointAngleFrom(_point) ;
    _footPoint = self.arcPoint(_angle) ;
    _distance = _footPoint.distanceToPoint(_point) ;

    return [_distance, _footPoint, _angle] ;
  end
  
  #----------------------
  #++
  ## 点までの距離
  ## _point_:: 対象となる Point
  ## *return*:: _distance_
  def distanceToPoint(_point)
    return distanceInfoToPoint(_point).first ;
  end
  
  #------------------------------------------
  #++
  ## 線分までの距離関係情報
  ## _line_:: 対象となる LineSegment。
  ## *return*:: [_distance_, _arcPoint_, _linePoint_]。
  def distanceInfoToLineSegment(_line)
    (_arcPoint, _linePoint) = self.closestPointPairFromLineSegment(_line)
    _distance = _arcPoint.distanceToPoint(_linePoint) ;

    return [_distance, _arcPoint, _linePoint] ;
  end

  #----------------------
  #++
  ## 線分までの距離
  ## _line_:: 対象となる LineSegment。
  ## *return*:: _distance_
  def distanceToLineSegment(_line)
    return distanceInfoToLineSegment(_line).first ;
  end

  #------------------------------------------
  #++
  ## 折れ線までの距離関係情報
  ## _lineString_:: 対象となる LineString。
  ## *return*:: [_distance_, _arcPoint_, _linePoint_, _lineSegment_]。
  def distanceInfoToLineString(_lineString)
    _minDistance = nil ;
    _minLine = nil ;
    _minArcPoint = nil ;
    _minLinePoint = nil ;

    _lineString.eachLine{|_line|
      (_distance, _arcPoint, _linePoint) =
        self.distanceInfoToLineSegment(_line) ;
      if(_minDistance.nil? || _minDistance > _distance) then
        _minDistance = _distance ;
        _minLine = _line ;
        _minArcPoint = _arcPoint ;
        _minLinePoint = _linePoint ;
      end
    }

    return [_minDistance, _minArcPoint, _minLinePoint, _line] ;
  end

  #----------------------
  #++
  ## 折れ線までの距離
  ## _lineString_:: 対象となる LineString。
  ## *return*:: _distance_
  def distanceToLineString(_lineString)
    return distanceInfoToLineString(_lineString).first ;
  end

  #------------------------------------------
  #++
  ## 円までの距離関係情報
  ## _otherCircle_:: 対象となる Ellipse (円である必要）
  ## *return*:: [_distance_, _selfPoint_, _otherPoint_]。
  def distanceInfoToEllipse(_otherCircle)
    (_selfPoint, _otherPoint) =
      self.closestPointPairFromEllipse(_otherCircle) ;
    _distance = _selfPoint.distanceToPoint(_otherPoint) ;

    return [_distance, _selfPoint, _otherPoint] ;
  end

  #----------------------
  #++
  ## 円までの距離
  ## _otherCircle_:: 対象となる Ellipse (円である必要）
  ## *return*:: _distance_。
  def distanceToEllipse(_otherCircle)
    return distanceInfoToEllipse(_otherCircle).first ;
  end
  
  #--////////////////////////////////////////////////////////////
  ## 出力
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
    ##  new
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

    #----------------------------------------------------
    #++
    ## foot point
    def test_b
      center = [1,1,1] ;
      axisMajor = Vector.new(rand() - 0.5, rand() - 0.5, rand() - 0.5).unit();
      axisMinor = Vector.new(rand() - 0.5, rand() - 0.5, rand() - 0.5).unit();
      circle = Ellipse.new(center, axisMajor, axisMinor) ;

      d = 3.0 ;
      point = Point.new(rand() - 0.5, rand() - 0.5, rand() - 0.5).unit(d);

      foot = circle.footPointFrom(point) ;
      footLine = LineSegment.new(point, foot) ;

      line = LineSegment.new(Point.new(rand() - 0.5,
                                       rand() - 0.5,
                                       rand() - 0.5).unit(d),
                             Point.new(rand() - 0.5,
                                       rand() - 0.5,
                                       rand() - 0.5).unit(d)) ;
      distPair = circle.closestPointPairFromLineSegment(line) ;
      distLine = LineSegment.new(*distPair) ;

      center2 = [0,0,0] ;
      axisMajor2 = Vector.new(rand() - 0.5, rand() - 0.5, rand() - 0.5).unit();
      axisMinor2 = Vector.new(rand() - 0.5, rand() - 0.5, rand() - 0.5).unit();
      circle2 = Ellipse.new(center2, axisMajor2, axisMinor2) ;

      distPair2 = circle.closestPointPairFromEllipse(circle2) ;
      distLine2 = LineSegment.new(*distPair2) ;

      p [:distPoint, circle.distanceInfoToPoint(point)] ;
      p [:distLine, circle.distanceInfoToLineSegment(line)] ;
      p [:distCircle, circle.distanceInfoToEllipse(circle2)] ;

      gconf = { xlabel: "X", ylabel: "Y", zlabel: "Z",
                xrange: [-3,3], yrange: [-3,3], zrange: [-3,3],
              } ;
      Gnuplot::directMulti3dPlot([:circle, :point, :foot,
                                  :line, :dist, :circle2, :dist2],
                                 gconf){|gplot|
        circle.draw(gplot, :circle) ;
        point.draw(gplot, :point) ;
        footLine.draw(gplot, :foot) ;
        
        line.draw(gplot, :line) ;
        distLine.draw(gplot, :dist) ;

        circle2.draw(gplot, :circle2) ;
        distLine2.draw(gplot, :dist2) ;
      }
    end

    #----------------------------------------------------
    #++
    ## tricky case
    def test_c
      circle0 = Ellipse.new([0,0,0], [0,0,10], [0,10,0]) ;
      circle1 = Ellipse.new([0,0,-1], [0,0,8], [8,0,0]) ;
      circle2 = Ellipse.new([0,0,0], [0,0,-10], [0,10,0]) ;

      distPair0 = circle1.closestPointPairFromEllipse(circle0) ;
      distLine0 = LineSegment.new(*distPair0) ;
      pp [:pair, distPair0] ;
      distPair2 = circle1.closestPointPairFromEllipse(circle2) ;
      distLine2 = LineSegment.new(*distPair2) ;
      pp [:pair, distPair2] ;

      gconf = { xlabel: "X", ylabel: "Y", zlabel: "Z",
                xrange: [-11,11], yrange: [-11,11], zrange: [-11,11],
              } ;
      Gnuplot::directMulti3dPlot([:circle0, :circle1, :circle2,
                                  :dist0, :dist2],
                                 gconf){|gplot|
        circle0.draw(gplot, :circle0) ;
        circle1.draw(gplot, :circle1) ;
        circle2.draw(gplot, :circle2) ;
        distLine0.draw(gplot, :dist0) ;
        distLine2.draw(gplot, :dist2) ;
      }
    end
    
    


  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
