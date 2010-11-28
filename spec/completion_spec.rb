require 'spec_helper'

feature 'completion' do
  scenario 'normal' do
    t('a 0 T1') # Today
    t('a T2')   # Next
    t('a 1 T3') # Scheduled

    t('l c').should have_completion_task('T1')
    t('l c').should have_completion_task('T2')
    t('l c').should have_completion_task('T3')
  end

  scenario 'recurring' do
    t('r a 1d T1')
    t('r c').should have_completion_task('T1')
  end
end
