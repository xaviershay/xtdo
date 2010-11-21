require 'spec_helper'

feature 'list' do
  scenario 'options' do
    t('a 0 T1')
    t('a T2')
    t('a 1 T3')

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
