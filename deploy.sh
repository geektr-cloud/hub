#!/usr/bin/env bash

hub::utils::let-dir-empty() {
  target_path="$1"
  # lesson written in blood
  # it's dangdangerous if $service_dir unset (following rm command will remove '/*' dir)
  if [ ! -n "$target_path" ]; then exit 1; fi

  if [ -d "$target_path" ]; then
    rm -rf "$target_path"/* "$target_path"/.*
  elif [ -f "$target_path" ]; then
    mv "$target_path" "$target_path.bak"
    mkdir -p "$target_path"
  else
    mkdir -p "$target_path"
  fi
}

hub::utils::sync() {
  source_path="$1"
  target_path="$2"

  hub::utils::let-dir-empty "$target_path"
  cp -r "$source_path/." "$target_path"
}

# constants
git_repo=https://github.com/geektr-cloud/hub.git
default_deploy_dir=/srv/geektr.cloud
default_backup_dir=/srv/geektr.cloud/.backups
default_project_name=hub

# set variables
# hub::set_deploy_conf [deploy_dir] [project_name] [deploy_dist]
hub::set_deploy_conf() {
  deploy_dist="${1:-$default_deploy_dir}"

  export project_name="${2:-$default_project_name}"
  export backups_dir="${3:-$default_backup_dir}"

  export service_dir="$deploy_dist/$project_name"

  export secrets_src="$deploy_dist/$project_name/secrets"
  export secrets_dir="$deploy_dist/$project_name.secrets"
  export secrets_bak="$backups_dir/$project_name.secrets"

  export data_src="$deploy_dist/$project_name/data"
  export data_dir="$deploy_dist/$project_name.data"
  export data_bak="$backups_dir/$project_name.data"
}

# shellcheck disable=SC2119
hub::set_deploy_conf

hub::dev_update() {
  if [ -d "$service_dir" ]; then
    pushd "$service_dir"
    docker-compose down || echo "already down"
    popd
  fi

  hub::utils::sync "$(pwd)" "$service_dir"
  find "$service_dir" -name ".gitkeep" -exec rm -rf '{}' +
}

# remove old project & get latest project by git
hub::update() {
  if [ -d "$service_dir" ]; then
    pushd "$service_dir"
    docker-compose down || echo "already down"
    popd
  fi

  hub::utils::let-dir-empty "$service_dir"
  git clone --depth=1 "$git_repo" "$service_dir"

  find "$service_dir" -name ".gitkeep" -exec rm -rf '{}' +
}

hub::backup-secrets() {
  mkdir -p "$backups_dir"

  backup_dir="$secrets_bak-$(date '+%y%m%d%H%M%S')"

  hub::utils::sync "$secrets_dir" "$backup_dir"
}

# initialize secret directory
hub::init-secrets() {
  # if secrets dir already exist, backup it and then remove
  if [ -d "$secrets_dir" ]; then
    hub::backup-secrets
    echo "$secrets_dir will be removed, you can find the backup in $backups_dir"
  fi

  hub::utils::sync "$secrets_src" "$secrets_dir"
}

hub::backup-data() {
  mkdir -p "$backups_dir"

  backup_file="$data_bak-$(date '+%y%m%d%H%M%S').zip"

  zip -rq "$backup_file" "$data_dir"
}

# initialize data directory
hub::init-data() {
  # if data dir already exist, backup it and then remove
  if [ -d "$data_dir" ]; then
    docker run --rm -it -v "$data_dir:/data" alpine:3.8 chown -R "$UID:$GID" /data
    hub::backup-data
    echo "$data_dir will be removed, you can find the backup in $backups_dir"
  fi

  hub::utils::sync "$data_src" "$data_dir"
}

hub::up() {
  envsubst < "$service_dir/.env.template" > "$service_dir/.env"

  pushd "$service_dir"
  docker-compose up -d
  popd
}

hub::caddy::reload() {
  pushd "$service_dir"
  docker-compose exec caddy pkill -USR1 caddy
  popd
}
