# Overview
- Setup MongoDB with Docker.
- Setup MongoExpress & MongoCompass to view database.

## Setting up MongoDB using Docker
  1. `docker pull mongo` to pull MongoDB Image.
  2. Run a MongoDB container using `docker run -d --name <name> -p 27017:27017 mongo`
    - `-d` to run it in detached mode
    - `-p` to set the port
    - default port for MongoDB is `27017`
  3. Verify it is running using `docker ps`
  4. To persist data, you can instead use one of 2 ways:
     - Volume Mounting
       - `docker run -dp 127.0.0.1:3000:3000 --mount type=volume,source=<volume_name>,target=/data/db mongo`
     - Bind Mounting
       - `docker run -d --name mongodb -p 27017:27017 --mount type=bind, source=/my/own/datadir,target=/data/db mongo`

## Setting up MongoDB using Docker Compose
  1. Create a compose.yaml in the root directory or add to an existing compose.yaml.
  2. Use the following code:
```yaml
services:
    mongodb:
        image: mongo:latest
        container_name: mongodb
        restart: always
        ports:
            # mapping ports on your pc to the port in the container
            - "27017:27017"
        volumes:
            - mongodb-data:/data/db # to persist data
        environment:
            MONGO_INITDB_ROOT_USERNAME: admin
            MONGO_INITDB_ROOT_PASSWORD: admin1

    mongo-express:
        image: mongo-express
        restart: always
        ports:
            - 8081:8081
        environment:
            ME_CONFIG_MONGODB_ADMINUSERNAME: admin
            ME_CONFIG_MONGODB_ADMINPASSWORD: admin1
            ME_CONFIG_MONGODB_URL: mongodb://admin:admin1@mongo:27017/
            ME_CONFIG_BASICAUTH: "false"
volumes:
    mongodb-data:
```
  - `image:` defines the image you are going to use
  - `container_name:` give the created container a name
  - `restart:` ensures the MongoDB container restarts automatically if it stops or if the Docker daemon restarts
  - `MONGO_INITDB_ROOT_USERNAME` sets the root username of the MongoDB database
  - `MONGO_INITDB_ROOT_PASSWORD` sets the root password of the MongoDB database
  - `ME_CONFIG_MONGODB_ADMINUSERNAME` provides the MongoDB admin username for MongoExpress to connect to MongoDB
  - `ME_CONFIG_MONGODB_ADMINPASSWORD` provides the MongoDB admin password for MongoExpress to connect to MongoDB
  - `ME_CONFIG_MONGODB_URL` specifies the connection URL to the MongoDB server
  - `ME_CONFIG_BASICAUTH` when set to false, it disables basic authentication for the Mongo Express web interface

  3. Run `docker compose up -d` for docker to read the `compose.yaml` and start the services
  4. If you want to view the logs, you can use `docker compose logs -f <service_name>`
  5. Run `docker compose down` to bring down the stack
    - Add `--volumes` to bring down the volumes as well
