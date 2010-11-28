require 'spec_helper'

feature 'add' do
  scenario 'to next' do
    t('a T1')
    t('l a').should have_task('T1', :in => :next)
  end

  scenario 'to today' do
    t('a 0 T1')
    t('l a').should have_task('T1', :in => :today)
  end

  scenario 'to scheduled' do
    t('a 1w T1')
    t('l a').should have_task('T1', :in => :scheduled, :for => Date.today + 7)
  end
end
