FROM ruby:2.6.3

RUN mkdir -p /dashboard-sdm

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN gem install bundler
RUN bundle install
RUN gem install bundler-audit

WORKDIR /dashboard-sdm
ADD . /dashboard-sdm
