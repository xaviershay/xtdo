require 'spec_helper'

feature 'recurring' do
  scenario 'daily' do
    t('recur 1d T1')

    time_travel Date.new(2010,11,18)
    t('list').should have_task('T1')
    t('bump 1 T1')
    t('list').should_not have_task('T1')
    t('done T1')
    t('list').should_not have_task('T1')

    time_travel Date.new(2010,11,19)
    t('list').should have_task('T1')
    t('done T1')

    time_travel Date.new(2010,11,21)
    t('list').should have_task('T1')
  end

  scenario 'weekly' do
    t('recur 1w,thu T1')

    time_travel Date.new(2010,11,18) # Thursday
    t('list').should have_task('T1')
    t('bump 1 T1')
    t('list').should_not have_task('T1')
    t('done T1')
    t('list').should_not have_task('T1') # Do not recreate the task

    time_travel Date.new(2010,11,25) # Next Thursday
    t('list').should have_task('T1')
    t('done T1')

    time_travel Date.new(2010,12,3) # Friday after
    t('list').should have_task('T1')
  end

  scenario 'monthly' do
    t('recur 1m,3 T1')

    time_travel Date.new(2010,11,3)
    t('list').should have_task('T1')
    t('bump 1 T1')
    t('list').should_not have_task('T1')
    t('done T1')
    t('list').should_not have_task('T1')

    time_travel Date.new(2010,12,3)
    t('list').should have_task('T1')
    t('done T1')

    time_travel Date.new(2011,1,4)
    t('list').should have_task('T1')
  end
end
