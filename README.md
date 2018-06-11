# link-shortener

A simple service built in Ruby on Rails for creating a bit.ly-like URL shortener.

By creating a url, you will receive a shortened link of 7 alpha-numeric characters (also known as a slug).

It is also possible to specify a custom slug using alpha-numeric characters, hyphens, and underscores.

## Design Decisions

### Short URL Algorithm

Generating short url slugs uses Ruby's SecureRandom library to generate a random url-safe base64 containing the 
characters A-Z, a-z, and 0-9. The starting length of n for this app is 5 in order to generate slugs 7 characters in length (as in the design spec).

The length of the slug can be adjusted by modifying n.

Per [RFC 3548](https://tools.ietf.org/html/rfc3548#page-6), this is effectively Base 62 since minus and understrike are omitted.

This gives us 62^7 possible short URLs or 3,521,614,606,208 possible (minus possible collisions created by custom-urls).

```
n = 5
SecureRandom.urlsafe_base64(n)
=> "QvGzBes"
```

With this implementation, I could only satisfy the requirement of generating a random shortlink, but could not make
it deterministic ("The same URL should always generate the same random shortlink"). Instead, the app satisfies this
requirement by performing a lookup if a shortlink for a given URL already exists and returns the URL in an error response.

### Tracking Visits

Visits are recorded as timestamped entries in a LinkVisit table containing a foreign key reference id to the Link 
model. The created_at timestamp is indexed for sorting and grouping by date.

To avoid adding additional infrastructure dependencies, this app records visits synchronously in the get method, but 
I would normally implement this using the Sidekiq or Resque gems for background  tasks using Redis for a queue. This 
is to avoid blocking the app redirects due to writes.

### URL Storage

URLs are stored in a PostgreSQL varchar field. Non-URL safe characters are escaped with the Ruby URI library.

## Development Environment Setup

The development and test environments use Docker and docker-compose to run.
For the database, the postgres:10.4-alpine Docker container is used.

To build the app's container and run migrations, install Docker and run:

```bash
docker-compose build
docker-compose run --rm web rake db:create db:migrate
docker-compose run --rm web rake db:migrate RAILS_ENV=test
docker-compose up

# Server is running at http://localhost:3000
```

To run tests in the docker container, after configuring the development environment and running DB migrations:
```bash
docker-compose run --rm web bundle exec rspec
```

## Redirection

### GET /[slug]

Visiting the root url followed by the slug or short link will redirect (status code 301) to the long url.

## JSON API

Authentication and updates were omitted to simplify the app, but I would want to ensure that only the original 
creator can update or destroy the resource (and possibly be the only one to view stats).

### POST /api/v1/links
Creates a new link with a required "url" parameter and an optional "slug" parameter.

#### Sample Request (Long URL Only)
```json
{
    "link": {
        "url": "https://www.google.com"
    }
}
```

#### Sample Response
```json
// Status: 201 CREATED

{
    "data": {
        "created_at": "2018-06-11T12:13:34Z",
        "short_url": "http://localhost:3000/stTWXlw",
        "url": "https://www.google.com"
    }
}
```

#### Sample Request (With custom slug)
This accepts a custom slug parameter.

```json
{
    "link": {
        "slug": "custom-slug",
        "url": "https://www.bing.com"
    }
}
```

#### Sample Response
```json
// Status: 201 CREATED

{
    "data": {
        "created_at": "2018-06-11T12:18:02Z",
        "short_url": "http://localhost:3000/custom-slug",
        "url": "https://www.bing.com"
    }
}
```

#### Errors

If a short link for the given url already exists, an error message containing the slug will be returned in an 
'errors' Array.

```json
// Status: 409 CONFLICT

{
    "errors": [
        "A short link for the url already exists at: http://localhost:3000/custom-slug"
    ]
}
```

If the slug already exists

```json
// Status: 400 BAD REQUEST

{
    "errors": [
        "Slug has already been taken"
    ]
}
```


#### GET /api/v1/links

Retrieves data about a given slug and optional stats.

#### Sample Request
```
#GET: /api/v1/[slug]
```
#### Sample Response

```json
// STATUS: 200 OK

{
    "data": {
        "created_at": "2018-06-11T12:18:02Z",
        "short_url": "http://localhost:3000/custom-slug",
        "url": "https://www.bing.com"
    }
}
```

#### Sample Request (with stats)

With the query parameter 'stats', the response will return stats under the 'meta' key.
* total_visits returns an integer
* visits_by_day returns a histogram of visits by day formatted an Array of key value pairs of the date (ISO 8601)
 and an integer.

#### Sample Request
```
#GET: /api/v1/[slug]?status=true
```
#### Sample Response

```json
// STATUS: 200 OK

{
    "data": {
        "created_at": "2018-06-11T12:18:02Z",
        "short_url": "http://localhost:3000/custom-slug",
        "url": "https://www.bing.com"
    },
    "meta": {
        "total_visits": 1,
        "visits_by_day": [
            {
                "2018-06-11T00:00:00Z": 1
            }
        ]
    }
}
```
