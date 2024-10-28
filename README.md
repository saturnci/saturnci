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
