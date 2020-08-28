CircleCI ORBs
=============

## Published Orbs

* [openjdk-install](https://circleci.com/orbs/registry/orb/cloudesire/openjdk-install)
* [maven](https://circleci.com/orbs/registry/orb/cloudesire/maven)
* [executors](https://circleci.com/orbs/registry/orb/cloudesire/executors)

## Developers

Creates a new orb:

    circleci orb create cloudesire/<name>

Publish dev version:

    circleci orb publish <name>.yml cloudesire/<name>@dev:first

Promote to production:

    circleci orb publish promote cloudesire/<name>@dev:first patch|minor|major
