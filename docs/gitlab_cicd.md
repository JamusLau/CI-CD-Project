
1. Create a __RUNNER__ and register it under your gitlab repository, using the Docker executor. (TLS should be enabled, for Docker-in-Docker)



```yml
default:
    image: docker:20.10.16
    services:
        - docker:20.10.16-dind
    before_script:
        # autenticate with docker
        - echo "$DOCKER_REGISTRY_PASSWORD" | docker login -u "$DOCKER_REGISTRY_USER" --password-stdin $DOCKER_REGISTRY
stages:
    - build
    - push
    - test
    - deploy-to-staging
    - deploy-to-prod

variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
    CONTAINER_TEST_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
    CONTAINER_RELEASE_IMAGE: $CI_REGISTRY_IMAGE:latest
    DOCKER_DRIVER: overlay2
    DOCKER_REGISTRY: docker.io
    DOCKER_IMAGE_NAME: my-image-name
    DOCKER_IMAGE_TAG: my-image-tag
    DOCKER_REGISTRY_USER: $DOCKER_USER
    DOCKER_REGISTRY_PASSWORD: $DOCKER_PASSWORD

# build the docker image
# need to have Dockerfile is the root of repo
build-job:
    stage: build
    script:
        - docker build -t $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG
    rules:
        - if: $CI_COMMIT_BRANCH = "main"
    only:
        - main

# push the docker image into the docker registry
push-job:
    stage: push
    script:
        # pushes the image onto docker registry
        - docker push $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG

# pull docker image and run tests on image
# call unit tests here
test-job:
    stage: test
    script:
        - docker pull $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG
        - docker run --rm $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME/$DOCKER_IMAGE_TAG bash -c "echo 'Running commands inside the container...'; my-command --arg1 value1; another-command"
        - docker run $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG /script/to/run/test
    tags:
        # use tags to signify which runner to use, will use runner with indicated tag

test-job2:
    stage: test
    # ../

deploy_to_staging:
    stage: deploy
    script:
    - echo "$EC2_SSH_PRIVATE_KEY" > /root/.ssh/id_rsa
    - chmod 600 /root/.ssh/id_rsa
    - ssh -o StrictHostKeyChecking=no ec2-user@$EC2_HOST << 'EOF'
        docker pull $IMAGE_TAG
        docker stop my_container || true
        docker rm my_container || true
        docker run -d --name my_container -p 8080:80 $IMAGE_TAG
      EOF
  only:
    - main
  environment:
    name: production

```

## Example use case between phpunit container and source code container
### Building tests files
```Dockerfile
# build only php tests, with dependencies
FROM php:8.1-cli

WORKDIR /app

COPY ./tests app/tests

# Install dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git

# Install php extensions
RUN docker-php-ext-install zip

# Install Composer (PHP dependency manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHPUnit (replace with the latest version if needed)
RUN curl -sS https://phar.phpunit.de/phpunit.phar -o /usr/local/bin/phpunit \
    && chmod +x /usr/local/bin/phpunit

# default command
CMD ["phpunit"]
```

### Building only source files
```Dockerfile
FROM ubuntu:latest

WORKDIR /app

COPY ./src app/src
```

### Test example
```yml
stages:
  - test

phpunit_tests:
  stage: test
  image: php:8.1-cli  # This is the test container with PHPUnit
  services:
    - name: my-source-image:latest  # Source code container
      alias: source  # Alias to access the source code
  before_script:
    # Install PHPUnit if not included in the image (optional)
    - curl -sS https://phar.phpunit.de/phpunit.phar -o /usr/local/bin/phpunit
    - chmod +x /usr/local/bin/phpunit
  script:
    # Copy code from source container to the test container if needed
    # You might need to handle this based on your actual setup
    - docker cp source:/path/to/source /app
    # Run PHPUnit tests
    - phpunit --configuration /app/phpunit.xml.dist
```

## Building multiple Docker images from one Dockerfile
```Dockerfile
FROM ubuntu:latest AS build
WORKDIR /app
COPY ./src app/src
# ../

FROM php:8.1-cli AS testBuild
WORKDIR /app
COPY ./tests app/tests
# ../
```

Build using targets: \
`docker build --target build -t myapp:build` \
`docker build --target testBuild -t myapp:testingBuild`


static application security testing using gitlab sast
- uses linux based gitlab runner
- php min gitlab version - 16.11
- c# min gitlab version - 15.4

```yml
include:
    - template: Jobs/SAST.gitlab-ci.yml
```



secret detection
- gitlab inbuilt secret detection
```yml
include:
    - template: Jobs/Secret-Detection.gitlab-ci.yml
```

Creating a local runner
create a volume to store config
`docker volume create gitlab-runner-config`

start the gitlab runner using the created volume
```yml
docker run -d --name gitlab-runner --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v gitlab-runner-config:/etc/gitlab-runner \
    gitlab/gitlab-runner:latest
```

to register the runner
`docker exec -it <runner-container-name> gitlab-runner register`
provide given information
`gitlab instance url` - gitlab url
`registration token` - token can be found under the project's settings: Settings > CI/CD > Runners > Set up a specific Runner manually
`Description` - Runner name
`Tags` - to tag the runner, so runners can be used for specific jobs
`Executor` - use docker
`Default Docker Image` - choose the default docker image e.g. ubuntu:latest