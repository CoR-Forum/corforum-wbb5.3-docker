# corforum-wbb5.3-docker

This repository provides a Docker stack for deploying CoR Forum based on WBB 5.3.

## Warning

This image is not meant to be used by the public as it requires forum data and an external database. It is made public for reference purposes only.

## Prerequisites

- Docker
- Docker Compose

## Data Requirements

This setup requires:
- Forum data files (e.g., attachments, avatars, etc.)
- An external database (MySQL or similar)

The database connection must be configured in the WBB config file.

## Setup

1. Clone this repository.
2. Navigate to the project directory.
3. Run `docker-compose up` to build and start the services.

## Usage

Once the containers are running, access the forum via the configured ports (typically http://localhost:8080).

## Configuration

Modify `docker-compose.yml` and `Dockerfile` as needed for your environment.

## Contributing

Feel free to submit issues or pull requests.