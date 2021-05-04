
# ClouDesire Common Orb

[![CircleCI Build Status](https://circleci.com/gh/ClouDesire/circleci-orbs.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/ClouDesire/circleci-orbs) [![CircleCI Orb Registry](https://img.shields.io/badge/orb-cloudesire%2Fcommon-informational)](https://circleci.com/orbs/registry/orb/cloudesire/common)

CircleCI Orb maintained by the Cloudesire development team, focusing on our stack (Spring Boot, Docker, Maven, GitHub, Opscode Chef)

> Documentation still incomplete, please take a look to the [sources](/src) or to the [registry](https://circleci.com/developer/orbs/orb/cloudesire/common) to have a complete overview.

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

When building a PR, the step `git_merge_default`, merges the PR branch with the default branch (main or master). 
Usage examples:

```yaml
- checkout

- cloudesire/git_merge_default

- cloudesire/maven_with_cache:
    mvn_path: ./mvnw
    steps:
      - run:
          name: Build
          command: ./mvnw -B package
```
