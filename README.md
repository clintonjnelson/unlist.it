#Unlist.it

This is the code for the unlist.it wishlist classifieds.

This code recently underwent a quick switch from private to public repo.
If you want to pull it down & run tests, you'll need a config/secrets.yml file like this:
```
test:
  secret_key_base: 853686b9b2fa0bd0eb6634c2a3c1815f42e4ed176c848efe42eb17ce63e0871694101cc5e119ed08e08f6f7ba9ff2e0ed6723dfd97b454c2031819382d5b9cb7
```
Note: some will still fail, since you won't have access to the amazon server. (old keys have been changed)



###About the codebase
This site was built with the Ruby on Rails framework.
The site runs on an PostgreSQL relational database. Currently using one dyno with multiple instances for traffic.
Background workers set up to handle maintenance tasks and non-performance critical tasks.
jQuery Ajax front end interactions for improved UX.
TDD & BDD aporoaches were commonly used for feature implementation.


####Features include:
- Fairly robust test suite (Run `rspec` in Shell after making a config/secrets.yml file per above. Failing are due to AWS access denial)
- OOP Rails structure for maintainability
- Location-based radius searches using Google Maps API (server location cacheing for speed)
- SSL (until recently due to co$t - will bring back if site picks up)
- Mail service for notification of activity & password resets
- AWS S3 photo storage
- Drag & Drop photo management
- Infinite Scroll
- Google Analytics
