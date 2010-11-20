require 'spec_helper'

feature 'recurring' do
  scenario 'daily' do
    t('recur 1d T1')
    t('list').should have_task('T1')
    t('bump 1 T1')
    t('list').should_not have_task('T1')
    t('done T1')
    t('list').should_not have_task('T1')
    time_travel('1d')
    t('list').should have_task('T1')
  end
end
