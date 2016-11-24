heroku pg:backups capture --app abroaders
curl -o latest.dump `heroku pg:backups public-url`
# If you're trying to use this file and you're not George, you'll probably need to change this line:
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U george -d abroaders_development latest.dump
rake db:environment:set RAILS_ENV=development
