# Run the full test suite locally.
#
# How I use this: 
#
# cd ..
# git clone abroaders ci
# # edit config for 'ci' repo so that it uses a different DB to the main repo
# # set up ENV vars for ci repo too if necessary
#
# Now I have a second copy of the codebase in the same dir as my main copy.
# When I want to run all the tests I open a new Terminal window and enter:
#
# cd ../ci
# git pull
# gco branch-to-test
# bin/ci.sh
#
# Now all my tests will run locally, and I can go back to my main repo and
# continue to work and edit without worrying that anything I do will interfere
# with the test run (and vica versa).
#
# Run bin/specs.sh to only run RSpec and skip ESLint/Rubocop

bundle install
npm install

rubocop # automatically uses config file in .rubocop.yml
if [ $? -ne 0 ]
then
  say "CI finished - build failed"
  exit 1
fi

eslint --ext ".js,.jsx" app/assets
if [ $? -ne 0 ]
then
  say "CI finished - build failed"
  exit 1
fi

rails db:environment:set db:drop db:create db:schema:load RAILS_ENV=test
rspec -f d
if [ $? -ne 0 ]
then
  say "CI finished - build failed"
  exit 1
fi

say "CI finished - build successful"
exit 0
