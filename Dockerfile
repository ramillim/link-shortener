FROM ruby:2.5.1-alpine3.7

ENV LANG C.UTF-8
ENV APP_HOME /app

RUN apk add --no-cache libstdc++ git postgresql-client build-base ruby-dev sqlite-dev postgresql-dev

RUN mkdir $APP_HOME

WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle

ENV PATH="${BUNDLE_BIN}:${PATH}"

RUN bundle check || bundle install --binstubs="$BUNDLE_BIN"

COPY . .
