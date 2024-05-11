FROM ruby:3.3.1-bookworm AS local

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y libffi-dev tini
RUN gem install jekyll

WORKDIR /app

COPY Gemfile Gemfile.lock /app
RUN bundle install

COPY . /app

EXPOSE 4000

ENTRYPOINT ["tini", "--"]
CMD bundle exec jekyll serve --host 0.0.0.0
