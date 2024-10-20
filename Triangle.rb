#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = Geo3D Triangle class
## Author:: Itsuki Noda
## Version:: 0.0 2024/10/04 I.Noda
##
## === History
## * [2024/10/04]: Create This File.
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

require 'Ring.rb' ;

module Itk ; module Geo3D ;
#--======================================================================
#++
## description of class Foo.
class Triangle < Ring
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## default values for WithConfParam#getConf(_key_).
  
  #--------------------------------------------------------------
  #++
  ## initialize.
  ## _pointList_:: Array of Point.
  def initialize(_pointList)
    super(_pointList) ;
  end

  #------------------------------------------
  #++
  ## set
  ## _pointList_:: Array of Point.
  ## _closeP_:: if true, force to close LineString.
  def set(_pointList,_closeP = true)
    if(_pointList.length() == 0) then
      raise "Triangle should have three Points.: " + _pointList.inspect() ;
    elsif(_pointList.length() > 3) then
      _pointList = _pointList[0,3] ;
    else
      while(_pointList.length < 3) do
        p [:warning, "too short pointList:" + _pointList.inspect] ;
        _pointList.push(_pointList.first) ;
      end
    end
    super(_pointList, true) ;
  end

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class Triangle
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
    ## about test_a
    def test_a
      ring = Ring.new([[1,0,0],[0,1,0],[0,0,1]]) ;
      pp [:ring, ring.toJson, ring] ;
      
      gconf = { xlabel: "X", ylabel: "Y", zlabel: "Z"} ;
      Gnuplot::directMulti3dPlot([:ring], gconf){|gplot|
        ring.draw(gplot, :ring) ;
      }
      
    end

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
