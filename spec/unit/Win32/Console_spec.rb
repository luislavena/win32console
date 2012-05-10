#!/usr/bin/env rspec

require 'spec_helper'
require 'Win32/Console'

describe Win32::Console do
  context '#initialize' do
    it 'ensure Attr is not called if output is redirected' do
      Win32::Console.any_instance.stubs(:redirected?).returns(true)
      Win32::Console.any_instance.expects(:Attr).never
      Win32::Console.new(Win32::Console::Constants::STD_OUTPUT_HANDLE)
    end

    # Negative test to the above, to make sure the test itself is working
    it 'ensure Attr is called if output is not redirected' do
      Win32::Console.any_instance.stubs(:redirected?).returns(false)
      Win32::Console.any_instance.expects(:Attr).at_least_once
      Win32::Console.new(Win32::Console::Constants::STD_OUTPUT_HANDLE)
    end
  end

  context '#redirected?' do
    it 'should return true if console is redirected' do
      subject.stubs(:Mode).returns(9999)
      subject.redirected?.should be_true
    end

    it 'should return false if console is not redirected' do
      subject.stubs(:Mode).returns(31)
      subject.redirected?.should be_false
    end
  end
end
