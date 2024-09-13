# Overview
Docker Compose is used to define multiple services within a single yaml file. Used to define your application stack in a file and keep it at the root of your project repository.

## Create a compose.yaml
Referencing a command: `docker run -dp 127.0.0.1:3000:3000 --mount type=volume, src=<volume_name>,target=<filepath> <image_name>`
```yaml
services:
    app:
        image: <image_name>
        command:
        ports:
            - 127.0.0.1:3000:3000
        working_dir: #working directory in the container
            - <filepath> # /src
        volumes: #can be relative paths from current directory
            - <volume_name>:<filepath_in_volume>
            - <relative_filepath> # ./:/src
        environment: #variable definitions
volumes: # to initialize and define volumes
    <volume_name>:
```

## Running the application stack
1. To start the application stack, use: `docker compose up -d`
    - `-d` to run it in the background
2. Use `docker ps` to see if the containers has started
3. Use `docker compose logs -f <service_name>` to view the logs of a specific service
4. Use `docker compose down` to bring down the stack
5. Use `docker rm -f <ids>` to remove the containers