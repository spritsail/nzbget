[hub]: https://hub.docker.com/r/spritsail/nzbget
[git]: https://github.com/spritsail/nzbget/tree/develop
[drone]: https://drone.spritsail.io/spritsail/nzbget
[mbdg]: https://microbadger.com/images/spritsail/nzbget:dev

# [Spritsail/NZBGet][hub]

[![Layers](https://images.microbadger.com/badges/image/spritsail/nzbget:dev.svg)][mbdg]
[![Latest Version](https://images.microbadger.com/badges/version/spritsail/nzbget:dev.svg)][hub]
[![Git Commit](https://images.microbadger.com/badges/commit/spritsail/nzbget:dev.svg)][git]
[![Docker Pulls](https://img.shields.io/docker/pulls/spritsail/nzbget.svg)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/spritsail/nzbget.svg)][hub]
[![Build Status](https://drone.spritsail.io/api/badges/spritsail/nzbget/status.svg)][drone]

An Alpine Linux based Dockerfile to run the usenet downloader NZBGet.
It expects a volume to store data mapped to `/config` in the container, and a volume where your downloads should go stored at `/downloads`. Enjoy!

This dockerfile uses a user with uid 904, and a gid of 900. Make sure this user has write access to the /config folder.
These user IDs can be overwritten by defining `$UID` and `$GID` respectively.

## Example run command
```
docker run -d --restart=on-failure:10 --name NZBGet -v /volumes/nzbget:/config -v /host/path/to/downloads:/downloads -p 6789:6789 spritsail/nzbget:develop
```
