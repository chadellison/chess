FROM ruby:2.6.4-alpine3.10

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update build-base \
    linux-headers \
    git \
    postgresql-dev \
    nodejs \
    tzdata

ENV APP_PATH /usr/src/app

WORKDIR ${APP_PATH}

COPY . ${APP_PATH}

RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

CMD ["sleep", "infinity"]
