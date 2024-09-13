# Overview
Volumes are used to persist data across instances of containers.

Two mounting methods:
- [Named Volume Mount](#named-volume-mounting): `type=volume,src=my-volume,target=/usr/local/data`
- [Bind Mount](#bind-mounting): `type=bind,src=/path/to/data,target=/usr/local/data`

# Named Volume Mounting
## 1. Creating a volume
- Create a volume by using `docker volume create <volume_name>`

## 2. Attaching volume to container
- First kill the intended container if its not using a persistent volume: `docker rm -f <container_id>`
- Use `docker run -dp 127.0.0.1:3000:3000 --mount type=volume, src=<volume_name>,target=<filepath> <image_name>`
  - Use `--mount` to specify a volume when starting a container
  - `type=volume` specifies that you are mounting a volume
  - `src=<volume_name>` specifies the volume you want to mount, by name
  - `target=<filepath>` specifies the path in the container we want to store in the volume.
- E.g. Intended filepath of data we want to store in the container is `/data/assets`
- Use `docker run -dp 127.0.0.1:3000:3000 --mount type=volume, src=<volume_name>,target=/data/assets <image_name>`

## 3. Inspecting the volume
- Use `docker volume inspect <volume_name>`

# Bind Mounting
Allows you to share a directory from the host's filesystem into the container. Changes will apply and reflect on both sides.

## 1. Attaching a volume
- Attach a volume by using `docker run -it --mount type=bind,src=<host_filepath>, target=<container_filepath> <image_name>`
    - Use `--mount` to specify that you are mounting
    - `type=bind` specifies that you are bind mounting
    - `src=<host_filepath>` directory on the host system you want to mount
    - `target=<filepath>` specifies the path in the container the directory should appear in
    - `-i` keeps the standard input open, lets users interact and send input to the container's processes
    - `-t` allocates a pseudo-TTY terminal as a terminal interface to the container

To try bind mounting, open a directory and try using: `docker run -it --mount type=bind,src="$(pwd)",target=/src ubuntu bash`. This mounts the current directory into the /src inside the container and starts an interactive bash session.