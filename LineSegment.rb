#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = Itk::Geo3D::LineSegment class
## Author:: Itsuki Noda
## Version:: 0.0 2024/09/09 I.Noda
##
## === History
## * [2024/09/09]: Create This File.
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

require 'pp' ;

require 'Point.rb' ;



module Itk ; module Geo3D ;
#--======================================================================
#++
## Line Segment class
class LineSegment < GeoObject
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## Default Point class
  PointClass = Point ;
  ## Default Vector class
  VectorClass = Vector ;
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## start point
  attr :u, true ;
  ## end point
  attr :v, true ;

  #--------------------------------------------------------------
  #++
  ## inisialization.
  ## _u_:: start point
  ## _v_:: end point
  ## _dupP_:: flag to duplicate _U_ and _v_.
  def initialize(_u = self.class::PointClass::new(), 
                 _v = self.class::PointClass::new(),
                 _dupP = false)
    set(_u,_v,_dupP) ;
  end

  #------------------------------------------
  #++
  ## set
  ## _u_:: start point
  ## _v_:: end point
  ## _dupP_:: flag to duplicate _U_ and _v_.
  def set(_u,_v,_dupP = false)
    _u = PointClass::sureGeoObject(_u) ;
    _v = PointClass::sureGeoObject(_v) ;
    @u = (_dupP ? _u.dup() : _u) ;
    @v = (_dupP ? _v.dup() : _v) ;

    return self ;
  end

  #------------------------------------------
  #++
  ## duplicate
  ## _deepP_:: flag to deep duplicate.
  def dup(_deepP = true)
    _lSeg = clone() ; 
    if(_deepP)
        _lSeg.u = self.u.dup() ;
        _lSeg.v = self.v.dup() ;
    end
    return _lSeg ;
  end

  #------------------------------------------
  #++
  ## reverse
  ## _dupP_:: flag to duplicate
  def reverse(dupP = false)
    return self.class.new(self.v, self.u, dupP) ;
  end

  #------------------------------------------
  #++
  ## shift
  ## _drift_:: amount of drift. a Vector.
  ## *return*:: a shifted Vector.
  def length()
    return @u.distanceTo(@v)
  end

  #------------------------------------------
  #++
  ## difference Vector
  ## *return*:: a difference Vector.
  def diffVector()
    return @v - @u ;
  end

  #--////////////////////////////////////////////////////////////
  # 推薦
  #--------------------------------------------------------------
  #++
  ## 垂線の足のある位置の u からの比率 k を求める
  ## _point_:: 垂線推薦を下ろす点。
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちら簡単点(0 or 1)となる。
  def footPointRatioFrom(_point, _extendP = true)
    _diff = self.diffVector() ;
    _rVec = _point - @u ;
    _d = _diff.sqLength() ;
    _k = ((_d == 0.0) ? 0.0 : (_diff.innerProd(_rVec).to_f / _d) ) ;

    ## adjust k if non-extendP mode.
    if(!_extendP) then
      if(_k < 0.0)
        _k = 0.0 ;
      elsif(_k > 1.0)
        _k = 1.0 ;
      end
    end

    return _k ;
  end

  #------------------------------------------
  #++
  ## 垂線の足のある位置の u からの距離を求める
  ## _point_:: 垂線を下ろす点
  ## _extendP_:: 線分の延長線上を許すかどうか。許さない場合、端点となる。
  def footPointSpanFrom(_point, _extendP = true)
    _k = footPointRatioFrom(_point, _extendP) ;
    return _k * length() ;
  end

  #------------------------------------------
  #++
  ## 垂線の足(最近点)のある位置。extendP が false の時は線分としての最近点
  ## _point_:: 垂線を下ろす点
  ## _extendP_:: 線分の延長線上を許すかどうか。許さない場合、端点となる。
  def footPointFrom(_point, _extendP = false)
    _k = footPointRatioFrom(_point, _extendP) ;

    _foot = @u + diffVector().amp(_k) ;

    return _foot ;
  end
  
  #--////////////////////////////////////////////////////////////
  # bbox and min/max XYZ
  #--------------------------------------------------------------
  #++
  ## minX
  def minX()
    return min(@u.x, @v.x) ;
  end

  #------------------------------------------
  #++
  ## maxX
  def maxX()
    return max(@u.x, @v.x) ;
  end

  #--------------------------------------------------------------
  #++
  ## minY
  def minY()
    return min(@u.y, @v.y) ;
  end

  #------------------------------------------
  #++
  ## maxY
  def maxY()
    return max(@u.y, @v.y) ;
  end

  #--------------------------------------------------------------
  #++
  ## minZ
  def minZ()
    return min(@u.z, @v.z) ;
  end

  #------------------------------------------
  #++
  ## maxZ
  def maxZ()
    return max(@u.z, @v.z) ;
  end
  

  #--////////////////////////////////////////////////////////////
  # convert
  #--------------------------------------------------------------
  #++
  ## to array
  def to_a()
    return [@u.to_a, @v.to_a] ;
  end

  #------------------------------------------
  #++
  ## to array
  def to_h()
    return { u: @u.to_h, v: @v.to_h } ;
  end

  #------------------------------------------
  #++
  ## to array
  def toJsonh()
    return { class: self.class.to_s, u: @u.toJson(), v: @v.toJson()} ;
  end
  
  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class LineSegment
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
    ## init, dup
    def test_a
      line0 = LineSegment.new() ;
      p [:line0, line0] ;
      line1 = LineSegment.new([1,2,3],[5,6,7]) ;
      p [:line1, line1] ;
      line2 = line1.dup() ;
      p [:line2, :dup, line2] ;
      line3 = line1.reverse() ;
      p [:line3, :rev, line3] ;
    end

    #----------------------------------------------------
    #++
    ## distance, min/max
    def test_b
      line0 = LineSegment.new([1,0,-1],[-1,4,3]) ;
      p [:line0, line0] ;
      p [:length, line0.length()] ;
      p [:min, line0.minX(), line0.minY(), line0.minZ()] ;
      p [:max, line0.maxX(), line0.maxY(), line0.maxZ()] ;
    end

    #----------------------------------------------------
    #++
    ## 垂線
    def test_c
      l0 = LineSegment.new([0,0,0],[1,1,1]) ;
#      p0 = Point.new([0,1,0]) ;
      p0 = Point.new([0,-1,0]) ;      
      p [:lp, l0.toJson, p0.to_a] ;
      p [:foot, l0.footPointFrom(p0).to_a] ;
      p [:foot, l0.footPointFrom(p0,true).to_a] ;
    end
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
