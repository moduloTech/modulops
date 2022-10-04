#
# BUILD IMAGE
#
FROM ruby:2.6-alpine

WORKDIR /app

RUN apk add --update --no-cache \
    alpine-sdk \
    tzdata

RUN gem install bundler -v 2.3.22

COPY . .

RUN bundle config set specific_platform true

# Install the basic dependencies
RUN bundle install

# Run the tests
CMD './docker-start.sh'
