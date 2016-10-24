bundle install
npm install

rails db:environment:set db:drop db:create db:schema:load RAILS_ENV=test
rspec -f d
if [ $? -ne 0 ]
then
  say "CI finished - build failed"
  exit 1
fi

say "CI finished - build successful"
exit 0
