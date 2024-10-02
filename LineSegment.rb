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
  # 垂線
  #--------------------------------------------------------------
  #++
  ## 垂線の足のある位置の u からの比率 k を求める
  ## _point_:: 垂線推薦を下ろす点。
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
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
  # 2線分の最近点
  #--------------------------------------------------------------
  #++
  ## 2つの線分の最近点の分率対を求める。
  ## 考え方：
  ##   線分 U:(U0,U1), V:(V0,V1) を考える。U0,U1,V0,V1 は端点を表すベクトル。
  ##     U上の点 Rp= (1-p) U0 + p U1 。
  ##     V上の点 Rq= (1-q) V0 + q V1 。
  ##   線分R:(Rp,R1)とすると、
  ##     Rの方向 = Rq-Rp = q(V1-V0) - p(U1-U0) + (V0-U0)
  ##   線分 R:(Rp,Rq) は U, V に直交する。よって、
  ##     (Rq-Rp)(U1-U0) = 0
  ##     (Rq-Rp)(V1-V0) = 0
  ##   よって、
  ##     q(U1-U0)(V1-V0) - p(U1-U0)^2 + (V0-U0)(U1-U0) = 0
  ##     q(V1-V0)^2 - p(U1-U0)(V1-V0) + (V0-U0)(V1-V0) = 0
  ##   ここで、
  ##     a = (U1-U0)^2
  ##     b = (V1-V0)^2
  ##     c = (U1-U0)(V1-V0)
  ##     g = (V0-U0)(U1-U0)
  ##     h = (V0-U0)(V1-V0)
  ##   としておくと、(以下、2行で行列・ベクトル)
  ##     [-a c] [p] = [-g]
  ##     [-c b] [q] = [-h]
  ##   左辺の行列の行列式は det = c^2 - ab となるので、
  ##   [p,q] の解は、
  ##     [p] = 1/    [b -c] [-g]
  ##     [q] =  /det [c -a] [-h]
  ##   つまり、
  ##     p = (1/det) (-bg + ch)
  ##     q = (1/det) (-cg + ah)
  ##   なお、det = 0 となるのは、
  ##     ab = c^2
  ##   つまり、
  ##     (U1-U0)^2 (V1-V0)^2 = ((U1-U0)(V1-V0))^2
  ##   これは、線分U,Vが平行の場合。
  ##   この場合は、p=q=0 として問題はない。
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: [p,q] の組。
  def closestFractionPairWith(_line, _extendP = false)
    _dU = self.diffVector() ;
    _dV = _line.diffVector() ;
    _dUV = _line.u - self.u ;
    _a = _dU.innerProd(_dU) ;
    _b = _dV.innerProd(_dV) ;
    _c = _dU.innerProd(_dV) ;
    _g = _dUV.innerProd(_dU) ;
    _h = _dUV.innerProd(_dV) ;
    _det = _c^2 - _a * _b ;

    if(isAlmostZero(_det)) then
      _p = 0.0 ;
      _q = 0.0 ;
    else
      _p = (_c * _h - _b * _g).to_f/_det ;
      _q = (_a * _h - _c * _g).to_f/_det ;
    end

    if(!_extendP) then
      _p = 0.0 if(_p < 0.0) ;
      _p = 1.0 if(_p > 1.0) ;
      _q = 0.0 if(_q < 0.0) ;
      _q = 1.0 if(_q > 1.0) ;
    end

    return [_p, _q] ;
  end

  #------------------------------------------
  #++
  ## 2つの線分の最近点を求める。
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: self と _line_ 上の点の組 [p,q]。
  def closestPointPairWith(_line, _extendP = false)
    (_p, _q) = self.closestFractionPairWith(_line, _extendP) ;
    _pointP = self.u * (1.0-_p) + self.v * _p ;
    _pointQ = _line.u * (1.0-_q) + _line.v * _q ;
    return [_pointP, _pointQ] ;
  end

  #------------------------------------------
  #++
  ## 2つの線分の最短距離を求める。
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: 最短距離。
  def closestDistanceWith(_line, _extendP = false)
    (_pointP, _pointQ) = self.closestPointPairWith(_line, _extendP) ;
    return _pointP.distanceTo(_pointQ) ;
  end

  #------------------------------------------
  #++
  ## 2つの線分の最短距離となる線分を求める。
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: 最短距離となる LineSegment
  def closestLineSegmentWith(_line, _extendP = false)
    (_pointP, _pointQ) = self.closestPointPairWith(_line, _extendP) ;
    return self.class.new(_pointP, _pointQ) ;
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
  ## to Hash
  def to_h()
    return { u: @u.to_h, v: @v.to_h } ;
  end

  #------------------------------------------
  #++
  ## to json
  def toJson()
    return { class: self.class.to_s, u: @u.toJson(), v: @v.toJson()} ;
  end

  #--////////////////////////////////////////////////////////////
  # draw
  #--------------------------------------------------------------
  #++ 
  ## draw by gnuplot
  ## _gplot_:: a Gnuplot object.
  ## _drawId_:: key in multi-plot.
  def draw(_gplot, _drawId = self.drawId())
    _line = to_a() ;
    _gplot.dm3pPlotLine(_drawId, _line) ;
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
      p0 = Point.new([0,1,0]) ;
      p1 = Point.new([0,-1,0]) ;      
      p [:lp, l0.toJson, p0.to_a, p1.to_a] ;
      foot00 = l0.footPointFrom(p0) ;
      foot01 = l0.footPointFrom(p0,true) ;
      foot10 = l0.footPointFrom(p1) ;
      foot11 = l0.footPointFrom(p1,true) ;
      p [:foot00, foot00.to_a] ;
      p [:foot01, foot01.to_a] ;
      p [:foot10, foot10.to_a] ;
      p [:foot11, foot11.to_a] ;
      fl00 = LineSegment.new(p0, foot00) ;

      gconf = {
        styleTable: {
          l0: { lw: 3, lc: "red" },
          p0: { lw: 1, lc: "blue" },
          p1: { lw: 1, lc: "gold" },
          foot00: { lw: 2, lc: "0x88009955" },
          foot01: { lw: 2, lc: "0x88999900" },
          foot10: { lw: 2, lc: "0x88990055" },
          foot11: { lw: 2, lc: "0x8800FF00" },
          fl00: { lw: 2, lc: "0x8800FF00" },
        },
      } ;
      
      Gnuplot::directMulti3dPlot([:l0, :p0, :p1,
                                  :foot00, :foot01,
                                  :foot10, :foot11,
                                  :fl00,
                                 ], gconf){|gplot|
        l0.draw(gplot, :l0) ;
        p0.draw(gplot, :p0) ;
        p1.draw(gplot, :p1) ;
        foot00.draw(gplot, :foot00) ;
        foot01.draw(gplot, :foot01) ;
        foot10.draw(gplot, :foot10) ;
        foot11.draw(gplot, :foot11) ;
        fl00.draw(gplot, :fl00) ;
      }
    end

    #----------------------------------------------------
    #++
    ## 線分との最近線分(closest with line)
    def test_d
      l0 = LineSegment.new([0,0,0],[1,1,1]) ;
      l1 = LineSegment.new([1,0,0],[1,1,0]) ;
      l2 = LineSegment.new([-1,0,-1],[-1,0,1]) ;
      p [:ll, l0.to_a, l1.to_a, l2.to_a] ;
      
      d01 = l0.closestLineSegmentWith(l1) ;
      p [:d01, d01.to_a] ;
      d02 = l0.closestLineSegmentWith(l2) ;
#      d02 = l0.closestLineSegmentWith(l2, true) ;
      p [:d02, d02.to_a] ;

      gconf = {
        styleTable: {
        },
      } ;
      Gnuplot::directMulti3dPlot([:l0, :l1, :l2, :d01, :d02], gconf){|gplot|
        l0.draw(gplot, :l0) ;
        l1.draw(gplot, :l1) ;
        l2.draw(gplot, :l2) ;
        d01.draw(gplot, :d01) ;
        d02.draw(gplot, :d02) ;
      }
      
      
    end
    
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
