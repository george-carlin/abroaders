heroku maintenance:on && git push heroku production:master && heroku run rake:db:migrate && heroku maintenance:off && git push origin production
