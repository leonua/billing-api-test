# README

Tested on Ruby 3.2.3

After fetching the project from git, 3 command should be enough:
`bundle install`
`rake db:migrate`
`rspec`

All dependencies are minimized, so no puma/assets/etc gems included, to simulate microservice/DB-only architecture
Database is sqlite for a same reason - minimize dependencies/configuration time.

Main files to check the code in:
  - spec/models/payment_spec.rb
  - app/models/payment.rb
  - lib/api/payment_provider_example.rb

Use global search 'TODO:' to find all comments and points of interest

`A maximum of 4 attempts is allowed for each rebill.` was understood like 1 time for 100%, 1 time for 75%,
not like 4 times for 100%, 4 times for 75%, etc...
Let me know if meant some other way.

If payment not 100% complete with successful response from a service = 1 week delay
If exception from our or payment provider sides (Exception/500 from any party) = 1 day delay

Multithread processing is not added, because require much more complex level of automation with rspec.

Some styling/structure of code is free to improve, I tried to keep it simple, 'all important part is on one screen/file'
and explained possible improvements in comments.