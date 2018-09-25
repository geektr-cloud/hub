# Hub

## Deploy

```bash
# source deploy script first
source <(wget -qO- https://raw.githubusercontent.com/geektr-cloud/hub/master/deploy.sh)

# update (init) project to local enviroment
hub::update

# when first run this init data directory and secrets directory
hub::init-data
hub::init-secrets

# edit secrets files
# vim xxxxxx

# up the services
hub::up
```

## Other Operation

```bash
source /srv/geektr.cloud/hub/deploy.sh

# backups
hub::backup-secrets
hub::backup-data

# reload web server
hub::caddy::reload
```
