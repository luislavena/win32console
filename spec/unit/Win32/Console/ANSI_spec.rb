#!/usr/bin/env rspec

require 'spec_helper'
require 'Win32/Console/ANSI'

describe Win32::Console::ANSI::IO do
  context '#initialize' do
    it 'should not call Win32::Console#Default* when console is redirected' do
      Win32::Console::ANSI::IO.any_instance.stubs(:redirected?).returns(true)
      Win32::Console.any_instance.expects(:DefaultForeground).never
      Win32::Console.any_instance.expects(:DefaultBackground).never
      Win32::Console.any_instance.expects(:DefaultBold).never
      Win32::Console.any_instance.expects(:DefaultUnderline).never
      Win32::Console::ANSI::IO.new
    end

    # Negative test for the above to make sure it is working
    it 'should call Win32::Console#Default* when console is not redirected' do
      Win32::Console::ANSI::IO.any_instance.stubs(:redirected?).returns(false)
      Win32::Console.any_instance.expects(:DefaultForeground).at_least_once
      Win32::Console.any_instance.expects(:DefaultBackground).at_least_once
      Win32::Console.any_instance.expects(:DefaultBold).at_least_once
      Win32::Console.any_instance.expects(:DefaultUnderline).at_least_once
      Win32::Console::ANSI::IO.new
    end
  end

  context '#redirected?' do
    it 'should return true if console is redirected' do
      Win32::Console.any_instance.stubs(:redirected?).returns(true)
      subject.redirected?.should be_true
    end

    it 'should return false if console is not redirected' do
      Win32::Console.any_instance.stubs(:redirected?).returns(false)
      subject.redirected?.should be_false
    end
  end
end
