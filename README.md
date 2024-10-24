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

To start your Phoenix server:

- Install asdf tools with `asdf install`
- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
