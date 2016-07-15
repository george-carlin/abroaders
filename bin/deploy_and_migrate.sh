heroku maintenance:on && git push heroku production:master && heroku run rails db:migrate && heroku maintenance:off && git push origin production
