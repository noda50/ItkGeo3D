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
      v = Itk::Geo3D::Vector.new() ;
      p [:v, :init, v] ;
      v.set(1,2,3) ;
      p [:v, :set123, v] ;
      
      u = Itk::Geo3D::Vector.new(5,6,7) ;
      p [:u, :init, u] ;
      v.set(u) ;
      p [:v, :setU, v] ;
      v.set([9,8,7]) ;
      p [:v, :setA, v] ;

      v.set([4,3]) ;
      p [:v, :setA2, v] ;
      
#      v.set(4,3) ;
#      p [:v, :setA3, v] ;
      
    end

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
