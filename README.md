## Setup

```bash
bin/setup
```

## Run the server

```bash
bin/dev
ngrok http 3000 --domain=$(echo NGROK_URL)
```

## Docker registry cache

Every job run starts with an image build.
When no gems have changed, it's pointless to perform a bundle install as part of the build process since nothing in that image layer has changed.
In order to cache the parts of the image that can be cached, we use something called a Docker [registry cache](https://docs.docker.com/build/cache/backends/registry/).

A registry cache is a way to cache Docker images on a remote server.
When a test suite is run on SaturnCI, the project's image is fetched from the registry cache,
which may or may not have some of its layers cached.
After the test suite has run, the new latest image, which may differ from the cached image, is pushed to the registry cache to be used next time.

The relevant Kubernetes files are located in `ops/production/registry'.

Relevant:
- https://hub.docker.com/_/registry
- https://docs.docker.com/docker-hub/mirror/
- https://docs.docker.com/build/cache/backends/registry/
