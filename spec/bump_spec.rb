require 'spec_helper'

feature 'bumping tasks' do
  scenario 'moving around' do
    t('add T1')
    t('list').should_not have_task('T1')
    t('bump 0 T1')
    t('list').should have_task('T1')
    t('bump 1 T1')
    t('list all').should have_task('T1', :in => :scheduled, :for => Date.today + 1)
    t('bump 1w T1')
    t('list all').should have_task('T1', :in => :scheduled, :for => Date.today + 7)
  end
end
