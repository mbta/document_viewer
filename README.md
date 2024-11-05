# DocumentViewer

Document Viewer is a web application allowing users with permission to view documents saved in secure S3 buckets. These documents might be things like signed forms and identification documents. The user is able to search by last name, first name, and date of birth, and list and view all documents relating to a given person.

[![Build Status](https://github.com/mbta/document_viewer/actions/workflows/elixir.yml/badge.svg)](https://github.com/mbta/document_viewer/actions/workflows/elixir.yml)

## Testing Docker

On MBTA machines docker for desktop is [not allowed](https://github.com/mbta/technology-docs/blob/main/rfcs/accepted/0010-docker-desktop-replacement.md). Instead you must first install Colma:

```sh
brew install colima docker
colima start
``

Then you can test building the docker container by:

```sh
docker build . -t document_viewer; docker run document_viewer
```

## Development

install deps
```sh
asdf install && mix deps.get
```

Likely you do not have the permissions to access the S3 bucket that this app connects to. That is deliberate. It houses very sensitive documents so the access to it is very locked down. If you start the app you may see an error like this:

```sh
[error] GenServer Catalog terminating
** (ArgumentError) errors were found at the given arguments:

  * 1st argument: the table identifier does not refer to an existing ETS table

    (stdlib 6.1.1) :ets.lookup(ExAws.Config.AuthCache, :aws_instance_auth)
    (ex_aws 2.5.3) lib/ex_aws/config/auth_cache.ex:23: ExAws.Config.AuthCache.get/1
    (ex_aws 2.5.3) lib/ex_aws/config.ex:179: ExAws.Config.retrieve_runtime_value/2
```

We have not yet setup a mock for the bucket in dev or setup a dev bucket to work from.

## Deploying

### Staging

The staging URL is [https://document-viewer-dev.mbtace.com](https://document-viewer-dev.mbtace.com).

If you do not have the correct permissions this may redirect back to `https://www.mbta.com/`. See [here](https://github.com/mbta/document_viewer/blob/main/lib/document_viewer_web/ensure_document_viewer_group.ex)

Merging to main deploys to the staging env automatically. There is also an action you can follow and trigger manually [here](https://github.com/mbta/document_viewer/actions/workflows/deploy-dev.yml).

### Prod

There is a github action for a prod deploy which can be found [here](https://github.com/mbta/document_viewer/actions/workflows/deploy-prod.yml)

## User Roles and Permissions

Details can be found [here](https://www.notion.so/mbta-downtown-crossing/Document-viewer-Roles-Groups-Users-130f5d8d11ea80c8b99bc40ed995171a)
