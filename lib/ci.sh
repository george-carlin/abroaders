bundle install
npm install
rails db:environment:set db:drop db:create db:schema:load RAILS_ENV=test
rspec -f p
if [ $? -eq 0 ]
then say "CI finished - build successful"
else say "CI finished - build failed"
fi
