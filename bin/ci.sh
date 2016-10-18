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
