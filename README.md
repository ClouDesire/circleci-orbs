
# ClouDesire Common Orb

[![CircleCI Build Status](https://circleci.com/gh/ClouDesire/circleci-orbs.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/ClouDesire/circleci-orbs) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/cloudesire/common)](https://circleci.com/orbs/registry/orb/cloudesire/common)

A starter template for orb projects. Build, test, and publish orbs automatically on CircleCI with [Orb-Tools](https://circleci.com/orbs/registry/orb/circleci/orb-tools).
Additional READMEs are available in each directory.

## Resources

### How to Publish

* Create and push a branch with your new features.
* When ready to publish a new production version, create a Pull Request from fore _feature branch_ to `master`.
* The title of the pull request must contain a special semver tag: `[semver:<segement>]` where `<segment>` is replaced by one of the following values.

| Increment | Description|
| ----------| -----------|
| major     | Issue a 1.0.0 incremented release|
| minor     | Issue a x.1.0 incremented release|
| patch     | Issue a x.x.1 incremented release|
| skip      | Do not issue a release|

Example: `[semver:major]`

* Squash and merge. Ensure the semver tag is preserved and entered as a part of the commit message.
* On merge, after manual approval, the orb will automatically be published to the Orb Registry.


### Commands

#### Docker: run and test container

To run and check if a container starts correctly, you can use the `docker_run_and_test` command. It runs the container and check, by default, the url http://localhost:8080/actuator/health waiting for the container to be `UP`.

If the container needs some environment variables, add a step before the `docker_run_and_test` command to create a `docker_env_file.list` file (look at the example for more)
Ex: 

```yaml
- run:
    name: Prepare docker env file
    command: |
      # Add the container env variables to a file. Es:
      # echo "SERVER_PORT=8080" >> docker_env_file.list

- cloudesire/docker_run_and_test:
    docker_registry: docker.cloudesire.com
    container_port_range: "8080:8080"

```

For the full list of parameters and default values check the [command page](https://circleci.com/developer/orbs/orb/cloudesire/common#commands-docker_run_and_test) in the orb documentation.

