# Rate Limit 
Rate limiting Rails App request by utilising Redis


## Dependencies

- Ruby  2.5.1
- Rails 5.2.3

## Install Redis

`brew install redis`

## Start Redis

`brew services start redis`

## Run API server

`rails server`

## Hit the server for 100 times to reach rate limit

`for ((i=1;i<=100;i++)); do   curl -v --header "Connection: keep-alive" "localhost:3000"; done`

## Next time you run below you will get 429 response
`curl http://localhost:3000/`

## Run Tests

`bundle exec rspec`

## Rate Limit Config
config/limit-rules.yml

## Middleware file 
lib/rack/attack.rb
