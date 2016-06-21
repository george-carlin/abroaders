# Domain and Hosting Information

In brief:

- The app is hosted on Heroku at abroaders.herokuapp.com. (We also have a
  staging app up at abroaders-staging.herokuapp.com)
- The domain Abroaders.com was bought from cheap-registrar.com, and it
  points to Bluehost's nameservers.
- The SSL certificate was also purchased from cheap-registrar.com. SSL
  is provisioned using Heroku's SSL add-on; you can see the SSL endpoint
  using `heroku certs`.
- The CSR for the SSL certificate was generated with the following info:


        Country Name (2 letter code) [AU]:US 
        State or Province Name (full name) [Some-State]:Michigan
        Locality Name (eg, city) []:Grand Ledge
        Organization Name (eg, company) [Internet Widgits Pty Ltd]:Abroaders
        Organizational Unit Name (eg, section) []:
        Common Name (e.g. server FQDN or YOUR name) []:app.abroaders.com
        Email Address []:george@abroaders.com
        Please enter the following 'extra' attributes
        to be sent with your certificate request
        A challenge password []:
        An optional company name []:Abroaders

- I've saved a copy in `/.ssl` of all the files that I had to generate while
  setting up SSL (`server.key`) etc. I'm not sure if we actually need to keep
  any of them around, but I figured I'd save them in this repo just in case we
  need them.
- The `server.pass.key` file was generated with the password
  `2a4f0f5c33a9f2d63dc5661886c8ceb6`.

