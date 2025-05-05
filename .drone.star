repo = "spritsail/nzbget"
architectures = ["amd64", "arm64"]
branches = ["master"]
tags = ["latest", "%label io.spritsail.version.nzbget"]


def main(ctx):
  builds = []
  depends_on = []

  for arch in architectures:
    key = "build-%s" % arch
    builds.append(step(arch, key))
    depends_on.append(key)
  if ctx.build.branch in branches:
    builds.extend(publish(depends_on))

  return builds


def step(arch, key):
  return {
    "kind": "pipeline",
    "name": key,
    "platform": {
      "os": "linux",
      "arch": arch,
    },
    "steps": [
      {
        "name": "build",
        "pull": "always",
        "image": "spritsail/docker-build",
      },
      {
        "name": "test",
        "pull": "always",
        "image": "spritsail/docker-test",
        "settings": {
          "curl": ":6789",
          "curl_opts": "-u nzbget:tegbzn6789",
          "delay": 5,
        },
      },
      {
        "name": "publish",
        "pull": "always",
        "image": "spritsail/docker-publish",
        "settings": {
          "registry": {"from_secret": "registry_url"},
          "login": {"from_secret": "registry_login"},
        },
        "when": {
          "branch": branches,
          "event": ["push"],
        },
      },
    ],
  }


def publish(depends_on):
  return [
    {
      "kind": "pipeline",
      "name": "publish-manifest-%s" % name,
      "depends_on": depends_on,
      "platform": {
        "os": "linux",
      },
      "steps": [
        {
          "name": "publish",
          "image": "spritsail/docker-multiarch-publish",
          "pull": "always",
          "settings": {
            "tags": tags,
            "src_registry": {"from_secret": "registry_url"},
            "src_login": {"from_secret": "registry_login"},
            "dest_registry": registry,
            "dest_repo": repo,
            "dest_login": {"from_secret": login_secret},
          },
          "when": {
            "branch": branches,
            "event": ["push"],
          },
        },
      ],
    }
    for name, registry, login_secret in [
      ("dockerhub", "index.docker.io", "docker_login"),
      ("spritsail", "registry.spritsail.io", "spritsail_login"),
      ("ghcr", "ghcr.io", "ghcr_login"),
    ]
  ]


# vim: ft=python sw=2
