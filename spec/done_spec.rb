require 'spec_helper'

feature 'done' do
  scenario 'marking off tasks' do
    t('a T1')
    t('l a').should have_task('T1')
    t('d T1').should == "Task done"
    t('l').should_not have_task('T1')
  end

  scenario 'invalid input' do
    t('d T1').should == "No such task"
  end
end
