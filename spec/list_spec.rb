require 'spec_helper'

feature 'list' do
  scenario 'options' do
    t('a 0 T1') # Today
    t('a T2')   # Next
    t('a 1 T3') # Scheduled

    # Today
    t('l').should have_task('T1')
    t('l').should_not have_task('T2')
    t('l').should_not have_task('T3')

    # All
    t('l a').should have_task('T1')
    t('l a').should have_task('T2')
    t('l a').should have_task('T3')
  end
end
