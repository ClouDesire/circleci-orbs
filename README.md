
# ClouDesire Common Orb

[![CircleCI Build Status](https://circleci.com/gh/ClouDesire/circleci-orbs.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/ClouDesire/circleci-orbs) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/cloudesire/common)](https://circleci.com/orbs/registry/orb/cloudesire/common)

CircleCI Orb developed by the ClouDesire Team. 

## Commands and examples

### Maven: install external library

To install an external library from another repository, use the `maven_install_library` command. It downloads the repository and installs the library on the build VM/container. 
Usage example:

```yaml
- cloudesire/maven_with_cache:
          mvn_path: ./mvnw
          steps:
            - cloudesire/maven_install_library:
                repo_url: git@github.com:my-organization/my-library.git
            - run:
                name: Build
                command: ./mvnw -B package
```


### Docker: run and test container

To run and check if a container starts correctly, you can use the `docker_run_and_test` command. It runs the container and check, by default, the url http://localhost:8080/actuator/health waiting for the container to be `UP`.

If the container needs some environment variables to run, add a step before the `docker_run_and_test` command to create a `docker_env_file.list` file (look at the example for more)
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


### Git
#### Merge PR branch with default branch (main/master)

When building a PR, the step `git_merge_master`, merges the PR branch with the default branch (either main or master). 
Usage examples:

```yaml
- checkout

- cloudesire/git_merge_master

- cloudesire/maven_with_cache:
    mvn_path: ./mvnw
    steps:
      - run:
          name: Build
          command: ./mvnw -B package
```
