# hub

this project deployed via [geektr-cloud/deployer](https://github.com/geektr-cloud/deployer)

## Deploy

```bash
# update (init) project to local enviroment
# when first run, it will init data directory and secrets directory
deployer update geektr-cloud/hub

# edit secrets files
# vim xxxxxx

# up the services
deployer up geektr-cloud/hub
```

## Other Operation

```bash
# reload web server
./caddy-reload.sh
```
