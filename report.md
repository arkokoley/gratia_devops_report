---
title: "Gratia: A DevOps Case Study"
author:
  - Gaurav Koley, IMT2014019 (Gaurav.Koley@iiitb.org)
  - Rajavaram Harika, IMT2014044 (Rajavaram.Harika@iiitb.org)
  - Shreyak Upadhyay, IMT2014049 (Shreyak.Upadhyay@iiitb.org)
geometry: margin=0.8in
date: May 11, 2018
---

# Executive Summary

# Software Development LifeCycle
!dot(imagename)(Software Development Life Cycle)
~~~~~ 
digraph {
  rankdir=LR;
  "SCM" -> "Build";
  "Build" -> "Testing";
  "Testing" -> "Artifact";
  "Artifact" -> Deployment;
  Deployment -> Monitoring;
}

~~~~~

![DevOps Pipeline](build_testing.png)

## SCM

The code is stored in a git repository hosted on GitHub at
[arkokoley/gratia](https://github.com/arkokoley/gratia).

## Build

## Testing

## Artifact 

The artifact, which in our case is a docker image is hosted in the Docker Hub
at [arkokoley/gratia](https://hub.docker.com/r/arkokoley/gratia/).

## Deployment

We use [Rundeck](https://www.rundeck.com/open-source) to manage automated
deployments on our production server which is managed by Zense.

We make use of the following Rundeck Job to deploy the latest docker image for Gratia:

```sh
# Shut down and remove existing containers
docker-compose down

# Pull Latest docker-compose.yml file
wget https://raw.githubusercontent.com/arkokoley/gratia/master/docker-compose-prod.yml \
-O docker-compose.yml

# Pull latest docker image
docker pull arkokoley/gratia

# Build new container
docker-compose up -d
```

## Monitoring

We use the [ElasticSearch, Logstash and Kibana (ELK)](https://www.elastic.co/elk-stack) stack to continuously
monitor Gratia in production.

### Setup the ELK Stack

Using Docker and docker-compose we setup ELK stack for the Gratia production
environment.

To do so, run the following commands:

```sh
# Clone a git repository containing necessary configuration files
git clone https://github.com/deviantony/docker-elk.git elk
cd elk
```

fix configuration for Logstash to support json input

`vi logstash/pipeline/logstash.conf`

and add `codec => "json_lines"` to the line below `port => 5000`.


Run the ELK stack using `docker-compose up -d`

### Configure Ruby on Rails for ELK

Since Gratia is a Ruby on Rails project, a few code changes are needed to
ensure that the logs are sent to Logstash as well as available in the log
files. 

This is done by following the given steps:

1. Add the following gems to `Gemfile` for logging.

```ruby
  # Gemfile 
  # For Logging
  gem 'lograge'
  gem 'logstash-event'
  gem 'logstash-logger'
```


2. Add the following lines to `config/environments/production.rb`:

```ruby

  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]
  # Logstash settings start here
  config.lograge.enabled = true
  config.lograge.keep_original_rails_log = true
  config.lograge.custom_payload do |controller|
  {
      host: "Gratia",
      user_id: controller.current_user.try(:id)
  }
  # The host option looks very interesting to be used with devise gem maybe
  end
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  # Optional, defaults to '0.0.0.0'
  config.logstash.host = ENV['LOGSTASH_HOST']  # Required, the port to connect to
  config.logstash.port = 5000  # Required
  config.logstash.type = :tcp
```

Optionally, repeat step 2 for other environments that may need logging.

# Results and Discussion

# Future Work

# Conclusion

# References
