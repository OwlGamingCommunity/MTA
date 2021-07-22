# OwlGaming MTA

This repository contains the OwlGaming MTA codebase for Multi Theft Auto. The recommended way to deploy the code is using a docker image.

## Credits

The code in this repository comes from various sources from probably nearly a decade of development. Thank you to everyone who contributed over the years.

## Building for release

- Build the image `docker build -t owlgaming-mta .`
- Refer to the environment variable below and deploy using your MySQL Database
```shell
docker run -p 22003:22003 -p 22005:22005 -p 22126:22126/udp -e MTA_DATABASE_NAME=... owlgaming-mta
```
- You can grab the latest structures for your database from `mods/deathmatch/data`

## Logs

Logs are written to `mods/deathmatch/resources/logs/logs` as they are created in game. It's recommended to pick these up using Filebeat with Elasticsearch to make them searchable.

## Quick Links

* [Coding Conventions](coding_conventions.md)
* [Useful Functions](useful_functions.md)

## Docker Build Environment Variables

### MTASERVER.CONF
- `SERVER_IP`
- `SHOULD_BROADCAST`
- `OWNER_EMAIL_ADDRESS`

### SETTINGS.XML
- `PRODUCTION_SERVER`
- `MTA_DATABASE_NAME`
- `MTA_DATABASE_USERNAME`
- `MTA_DATABASE_PASSWORD`
- `MTA_DATABASE_HOST`
- `MTA_DATABASE_PORT`

- `CORE_DATABASE_NAME`
- `CORE_DATABASE_USERNAME`
- `CORE_DATABASE_PASSWORD`
- `CORE_DATABASE_HOST`
- `CORE_DATABASE_PORT`

- `FORUMS_API_KEY`
- `IMGUR_API_KEY`
