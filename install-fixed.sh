#!/usr/bin/env bash

# OutlineAdmin + Caddy public installer
# Supported OS: Ubuntu 22.04 / 24.04
# Fresh installations only.

set -Eeuo pipefail
umask 077

DIR="/opt/outline-admin"
PROJECT="outline-admin"
DOMAIN=""
PASSWORD=""
IPV4="Not detected"
IPV6="Not detected"
INSTALL_STARTED=0

info() {
  printf '\n[INFO] %s\n' "$*"
}

die() {
  printf '\n[ERROR] %s\n' "$*" >&2
  exit 1
}

dc() {
  docker compose \
    --project-name "$PROJECT" \
    --project-directory "$DIR" \
    -f "$DIR/compose.yaml" \
    "$@" </dev/null
}

on_error() {
  local status="$1"
  local line="$2"

  trap - ERR

  printf '\n[ERROR] Installation stopped at line %s (exit %s).\n' \
    "$line" "$status" >&2

  if [[ "$INSTALL_STARTED" == "1" ]]; then
    printf 'Files have NOT been deleted: %s\n' "$DIR" >&2
    printf 'Inspect status: cd %s && sudo docker compose ps\n' \
      "$DIR" >&2
    printf 'Inspect logs: cd %s && sudo docker compose logs --tail=80\n' \
      "$DIR" >&2

    if [[ -f "$DIR/credentials.txt" ]]; then
      printf 'Saved credentials: sudo cat %s/credentials.txt\n' \
        "$DIR" >&2
    fi
  fi

  exit "$status"
}

trap 'on_error "$?" "$LINENO"' ERR

ask_domain() {
  local value=""

  if ! { exec 3<>/dev/tty; } 2>/dev/null; then
    die "An interactive terminal is required. Run this installer from SSH."
  fi

  while true; do
    printf 'Enter your domain (example: panel.example.com): ' >&3

    if ! IFS= read -r value <&3; then
      exec 3>&-
      die "Could not read the domain."
    fi

    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    value="${value,,}"

    if (( ${#value} <= 253 )) &&
      [[ "$value" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?(\.[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)+$ ]] &&
      [[ ! "$value" =~ ^[0-9.]+$ ]]; then
      DOMAIN="$value"
      break
    fi

    printf 'Invalid domain. Enter a hostname without https://, port, or path.\n' >&3
  done

  exec 3>&-
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    info "Using the existing Docker installation."

    if ! docker compose version >/dev/null 2>&1; then
      die "Docker exists, but Docker Compose v2 is missing. Install its Compose plugin, then rerun. Existing Docker packages were not changed."
    fi
  else
    local package

    for package in docker.io docker-compose docker-compose-v2 \
      podman-docker containerd runc; do
      if dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
        grep -qx 'install ok installed'; then
        die "Existing package '$package' may conflict with Docker CE. Resolve the container-runtime installation before continuing."
      fi
    done

    info "Installing Docker from its official Ubuntu repository."

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL --retry 3 \
      --connect-timeout 10 --max-time 120 \
      https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc

    chmod 0644 /etc/apt/keyrings/docker.asc

    printf \
      'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu %s stable\n' \
      "$(dpkg --print-architecture)" "$VERSION_CODENAME" \
      > /etc/apt/sources.list.d/docker.list

    chmod 0644 /etc/apt/sources.list.d/docker.list

    apt-get update

    apt-get install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin
  fi

  systemctl enable --now docker

  docker info >/dev/null
  docker compose version >/dev/null
}

main() {
  [[ "$EUID" -eq 0 ]] ||
    die "Run this installer as root: sudo bash install.sh"

  [[ -r /etc/os-release ]] ||
    die "Cannot identify the operating system."

  . /etc/os-release

  if [[ "${ID:-}" != "ubuntu" ]]; then
    die "This installer supports Ubuntu 22.04 and 24.04 only."
  fi

  case "${VERSION_ID:-}" in
    22.04|24.04) ;;
    *) die "This installer supports Ubuntu 22.04 and 24.04 only." ;;
  esac

  [[ -d /run/systemd/system ]] ||
    die "A systemd-based Ubuntu server is required."

  if [[ -e "$DIR" || -L "$DIR" ]]; then
    die "$DIR already exists. Nothing was overwritten. This installer is for fresh installations."
  fi

  printf '\n=========================================\n'
  printf '      OutlineAdmin Auto-Installer\n'
  printf '=========================================\n'
  printf 'Installs the management panel, not Outline Server.\n\n'

  ask_domain

  info "Installing prerequisites."

  export DEBIAN_FRONTEND=noninteractive

  apt-get update

  apt-get install -y \
    ca-certificates \
    curl \
    openssl \
    iproute2

  info "Checking required TCP ports."

  local port listeners

  for port in 80 443 3000; do
    listeners="$(ss -H -ltn "sport = :$port")"

    if [[ -n "$listeners" ]]; then
      die "TCP port $port is already in use. No application files were created."
    fi
  done

  install_docker

  local existing

  existing="$(docker ps -aq \
    --filter "label=com.docker.compose.project=$PROJECT")"

  [[ -z "$existing" ]] ||
    die "Containers belonging to '$PROJECT' already exist. Nothing was overwritten."

  existing="$(docker volume ls -q \
    --filter "label=com.docker.compose.project=$PROJECT")"

  [[ -z "$existing" ]] ||
    die "Data volumes belonging to '$PROJECT' already exist. They were preserved."

  info "Detecting public IP addresses."

  if ! IPV4="$(curl -4 -fsS \
    --connect-timeout 5 --max-time 10 \
    https://api.ipify.org 2>/dev/null)"; then
    IPV4="Not detected"
  fi

  if ! IPV6="$(curl -6 -fsS \
    --connect-timeout 5 --max-time 10 \
    https://api64.ipify.org 2>/dev/null)"; then
    IPV6="Not detected"
  fi

  IPV4="${IPV4:-Not detected}"
  IPV6="${IPV6:-Not detected}"

  printf 'Public IPv4: %s\n' "$IPV4"
  printf 'Public IPv6: %s\n' "$IPV6"

  info "Creating application configuration."

  mkdir -m 0700 "$DIR"
  INSTALL_STARTED=1

  PASSWORD="$(openssl rand -hex 24)"

  cat > "$DIR/compose.yaml" <<'COMPOSE'
services:
  admin:
    image: amro045/outline-admin:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:3000:3000"
    volumes:
