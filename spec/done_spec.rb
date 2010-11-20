require 'spec_helper'

feature 'done' do
  scenario 'marking off tasks' do
    t('add T1')
    t('list all').should have_task('T1')
    t('done T1')
    t('list').should_not have_task('T1')
  end
end
