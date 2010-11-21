require 'spec_helper'

feature 'bumping tasks' do
  scenario 'moving around' do
    t('a T1')
    t('l').should_not have_task('T1', :in => :today)
    t('b 0 T1')
    t('l').should have_task('T1', :in => :today)
    t('b 1 T1')
    t('l all').should have_task('T1', :in => :scheduled, :for => Date.today + 1)
    t('b 1w T1')
    t('l a').should have_task('T1', :in => :scheduled, :for => Date.today + 7)
  end

  scenario 'invalid input' do
    t('b 0 T1').should == 'No such task'
    t('b T1').should == 'Invalid time'
  end
end
