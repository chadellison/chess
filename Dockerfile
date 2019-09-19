FROM ruby:2.6.4-alpine3.10

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update build-base \
    linux-headers \
    git \
    postgresql-dev \
    nodejs \
    tzdata

ENV APP_PATH /usr/src/app/ REDISTOGO_URL redis://cache:6379/1

WORKDIR ${APP_PATH}

COPY Gemfile Gemfile.lock ${APP_PATH}

RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

COPY . ${APP_PATH}

CMD ["./scripts/load_games.sh", "10", "db"]

