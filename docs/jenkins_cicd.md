## References
https://github.com/devopsjourney1/jenkins-101

## Running Jenkins as a Docker Container
### 1. Create a Dockerfile to pull the latest Jenkins version and build an Image.
```Dockerfile
FROM jenkins/jenkins:<version> #2.462.2-jdk11
USER root
RUN apt-get update && apt-get install -y lsb-release python3-pip
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.3 docker-workflow:1.28"
```
`docker build -t <name_of_image> .`

### 2. Create the Jenkins Network
Use `docker network create jenkins` to create the network.\
Use `docker network ls` to verify.

### 3. Run the Jenkins container and connect to it locally.
```powershell
docker run --name jenkins-blueocean --restart=on-failure --detach `
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 `
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 `
  --volume jenkins-data:/var/jenkins_home `
  --volume jenkins-docker-certs:/certs/client:ro `
  --publish 8080:8080 --publish 50000:50000 myjenkins-blueocean:<version>
```

Verify the IP using `docker ps` or use `https://localhost:8080` to connect and access the Jenkins GUI.

### 4. Getting your password and logging in.
Use this command to get the initial password to login: \
`docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword`

Unlock Jenkins using the password that was given after the command.

## Jobs in Jenkins

`New Item > Freestyle Project`  
Note: Name cannot have spaces \
Enable options as needed.


## Agents

Dashboard > Manage Jenkins

Nodes - Linux/Windows Server that you own that is always up, connected to Jenkins via SSH, Jenkins will distribute jobs to it, e.g. physical computeres or virtual machines.

Clouds - Agents using cloud platforms, e.g. Docker, Kubernetes, AWS.

For this, use Docker.

Clouds > Install Plugins

Find Docker, install and restart.

Enter name, click next,

to run agent within jenkins, put 127.0.0.1,
to connect to docker container running the agent:
First create a container running the alpine socat image, acts as a proxy from the local jenkins container to the agent
```powershell
docker run -d --restart=always -p 127.0.0.1:2376:2375 --network jenkins -v /var/run/docker.sock:/var/run/docker.sock alpine/socat tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock
```
```powershell
docker inspect <container_id> | grep IPAddress
```
find the ipaddress under Networks>Jenkins>IPAddress
enter it on jenkins Docker Host URI as tcp://ipaddress:2375
Check "Enabled" and save.

Go Configure of the cloud agent you just created, go to docker agent templates and create.
Labels - Used to tell Jenkins which agents to use for the build
"Enabled" - Check it
Name - Just a name
Docker Image - agent image to use, can try `jenkins/agent:alpine-jdk11`, use a template needed by your use case
You can create your own agent as well, e.g. python
```Dockerfile
FROM jenkins/agent:alpine-jdk11
USER root
RUN apk add python3
RUN apk add py3-pip
USER jenkins
```
Instance Capacity - Reco 2
Remote file system root - /home/jenkins
everything else default


in your job's configure
General settings > Restrict where this project can be run
Enter the label of the agent you just created