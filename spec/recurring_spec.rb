require 'spec_helper'

feature 'recurring' do
  describe 'extract_r_tokens' do
    it { Xtdo.extract_recur_tokens('1d T1').should == ['1', 'd', nil, 'T1'] }
    it { Xtdo.extract_recur_tokens('1w,thu T1').should == ['1', 'w', 'thu', 'T1'] }
    it { Xtdo.extract_recur_tokens('1m,2 T1').should == ['1', 'm', '2', 'T1'] }
    it { Xtdo.extract_recur_tokens('1m,20 T1').should == ['1', 'm', '20', 'T1'] }
  end

  describe 'starting day' do
    let(:today) { Date.new(2010,11,22) } # Monday

    it { Xtdo.calculate_starting_day(today, 1, 'd').should == today + 1 }
    it { Xtdo.calculate_starting_day(today, 1, 'w', 'mon').should == today + 7}
    it { Xtdo.calculate_starting_day(today, 1, 'w', 'tue').should == today + 1}
    it { Xtdo.calculate_starting_day(today, 1, 'w', 'sun').should == today + 6}
    it { Xtdo.calculate_starting_day(today, 1, 'w', '0').should == nil }
    it { Xtdo.calculate_starting_day(today, 1, 'm', '1').should == Date.new(2010,12,1)}
    it { Xtdo.calculate_starting_day(today, 1, 'm', '22').should == Date.new(2010,12,22)}
    it { Xtdo.calculate_starting_day(today, 1, 'm', '23').should == Date.new(2010,11,23)}
    it { Xtdo.calculate_starting_day(today, 1, 'm', '0').should == nil }
  end

  let(:today) { Date.new(2010,11,17) } # Monday

  scenario 'list' do
    t('r a 1d T1')
    t('r l').should have_task('1d      T1')
  end

  scenario 'daily' do

    time_travel today
    t('r a 1d T1')

    time_travel today + 1
    t('l').should have_task('T1')
    t('b 1 T1')
    t('l').should_not have_task('T1')
    t('d T1')
    t('l').should_not have_task('T1')

    time_travel today + 2
    t('l').should have_task('T1')
    t('d T1')

    time_travel today + 4
    t('l').should have_task('T1')
  end

  scenario 'remove' do
    time_travel today
    t('r a 1d T1')
    t('r d T1')
    time_travel today + 1
    t('l a').should_not have_task('T1')
  end

  scenario 'weekly' do
    time_travel today
    t('r a 1w,thu T1')

    time_travel Date.new(2010,11,18) # Thursday
    t('l').should have_task('T1')
    t('b 1 T1')
    t('l').should_not have_task('T1')
    t('d T1')
    t('l').should_not have_task('T1') # Do not recreate the task

    time_travel Date.new(2010,11,25) # Next Thursday
    t('l').should have_task('T1')
    t('d T1')

    time_travel Date.new(2010,12,3) # Friday after
    t('l').should have_task('T1')
  end

  scenario 'monthly' do
    time_travel today
    t('r a 1m,3 T1')

    time_travel Date.new(2010,12,3)
    t('l').should have_task('T1')
    t('b 1 T1')
    t('l').should_not have_task('T1')
    t('d T1')
    t('l').should_not have_task('T1')

    time_travel Date.new(2011,1,4)
    t('l').should have_task('T1')
  end

  scenario 'error' do
    t('r a').should == "Invalid command"
  end
end
