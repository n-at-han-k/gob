FROM ruby:3.3-slim AS build

COPY --from=golang:1.22 /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN bundle exec gob build src/main.gob -o /go/bin/app

FROM gcr.io/distroless/static-debian13

COPY --from=build /go/bin/app /
CMD ["/app"]
