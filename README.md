[![](https://images.microbadger.com/badges/image/steffenblake/nginx-static-ha.svg)](https://microbadger.com/images/steffenblake/nginx-static-ha "Get your own image badge on microbadger.com") ![](https://img.shields.io/docker/pulls/steffenblake/nginx-static-ha.svg)

# Super Lightweight High Avialability fork of docker-nginx-static

`docker run -v /absolute/path/to/serve:/static -p 8080:80 steffenblake/nginx-static-ha`

This command exposes an nginx server on port 8080 which serves the folder `/absolute/path/to/serve` from the host.

One boot up this image copies all directories and files from `/absolute/path/to/serve` to its own internal `/www` directory. Thus once initialization is complete, modifications to `/absolute/path/to/serve` will **not** be reflected by, or impact, the served nginx directory. To 'refresh' the served files the docker image must be redeployed. This is conducive to a "high avialability" system where you want to perform rolling deployments, thus you can modify the static files and roll out a deployment without suffering any outages.

If you want an instant reflected service that does not have this behavior, see the *original* `nginx-static` image that this repo is a fork of here: https://github.com/flashspys/docker-nginx-static

The image can only be used for static file serving but is **less than 4 MB** (roughly 1/10 the size of the official nginx image). The running container needs **~1 MB RAM**.

### nginx-static via HTTPS

To serve your static files over HTTPS you must use another reverse proxy. We recommend [træfik](https://traefik.io/) as a lightweight reverse proxy with docker integration. Do not even try to get HTTPS working with this image only, as it does not contain the nginx ssl module.

## nginx-static-ha with docker-compose
This is an example entry for a `docker-compose.yaml`
```yaml
version: '3'
services:
  example.org:
    image: steffenblake/nginx-static-ha
    container_name: example.org
    ports:
      - 8080:80
    volumes: 
      - /path/to/serve:/static
```


## nginx-static with træfik 2.x

To use nginx-static-ha with træfik 2.x add an entry to your services in a docker-compose.yaml. To set up traefik look at this [simple example](https://docs.traefik.io/user-guides/docker-compose/basic-example/). 

In the following example, replace everything contained in \<angle brackets\> and the domain with your values.

```yaml
services:
  traefik:
    image: traefik:2.4 # check if there is a newer version
  # Your traefik config.
    ...
  example.org:
    image: steffenblake/nginx-static-ha
    container_name: example.org
    expose:
      - 80
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.<router>.rule=Host(`example.org`)"
      - "traefik.http.routers.<router>.entrypoints=<entrypoint>"
# If you want to enable SSL, uncomment the following line.
#      - "traefik.http.routers.<router>.tls.certresolver=<certresolver>"
    volumes: 
      - /host/path/to/serve:/static
```

If traefik and the nginx-static-ha are in distinct docker-compose.yml files, please make sure that they are in the [same network](https://doc.traefik.io/traefik/routing/providers/docker/#traefikdockernetwork).

For a traefik 1.7 example look [at an old version of the readme](https://github.com/flashspys/docker-nginx-static/blob/bb46250b032d187cab6029a84335099cc9b4cb0e/README.md)

### Custom nginx config

In the case you already have your own Dockerfile you can easily adjust the nginx config by adding the following command in your Dockerfile. In case you don't want to create an own Dockerfile you can also add the configuration via volumes, e.g. appending `-v /absolute/path/to/custom.conf:/etc/nginx/conf.d/default.conf` in the command line or adding the volume in the docker-compose.yaml respectively. This can be used for advanced rewriting rules or adding specific headers and handlers. See the default config [here](nginx.vh.default.conf).

```dockerfile
…
FROM steffenblake/nginx-static-ha
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY your-custom-nginx.conf /etc/nginx/conf.d/default.conf
```

Or you can just mount the docker file post image compilation in docker compose:

```yaml
version: '3'
services:
  example.org:
    image: steffenblake/nginx-static-ha
    container_name: example.org
    ports:
      - 8080:80
    volumes: 
      - /path/to/serve:/static
      - /path/to/nginx/default.conf:/etc/nginx/conf.d/default.conf
```
