GitLab Push/MR -> GitLab Checking before Build -> Jenkins Build -> Jenkins Testing -> Deployment

Stage 2: Syntax checking etc.
Stage 3: Trigger jenkins build
update status in gitlab

Stage 4: Trigger jenkins build testing
update status in gitlab

Stage 5: Deployment



## References
https://github.com/devopsjourney1/jenkins-101
https://docs.gitlab.com/ee/integration/jenkins.html


## Running Jenkins as a Docker Container
### 1. Create a Dockerfile to pull the latest Jenkins version and build an Image.
```Dockerfile
FROM jenkins/jenkins:<version> #2.462.2-jdk21
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

1. Go to `Dashboard` > `Manage Jenkins`, you will see two tabs under `System Configuration`: `Clouds` and `Nodes`.

    `Nodes` - Linux/Windows Server that you own that is always up, connected to Jenkins via SSH, Jenkins will distribute jobs to it, e.g. physical computeres or virtual machines.

    `Clouds` - Agents using cloud platforms, e.g. Docker, Kubernetes, AWS.

2. For this, use Docker.
   1. Clouds > Install Plugins
   2. Find Docker, install and restart

3. Create a new cloud on Jenkins
   1. Click on Clouds
   2. New Cloud +
   3. Enter name, select Docker and Create.

4. Create an agent on Docker
   1. First create a container running the alpine socat image, acts as a proxy from the local jenkins container to the agent, forwards the traffic from Jenkins to the Docker Desktop container on the host machine. Use different port numbers for different agents.

    ```powershell
    docker run -d --restart=always -p 127.0.0.1:<port>:2375 --network jenkins -v /var/run/docker.sock:/var/run/docker.sock alpine/socat tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock
    ```

    2. To connect to docker container running the agent: find the `IPAddress` under `Networks > Jenkins > IPAdress`, after running the command `docker inspect <container_id> | grep IPAddress`, then enter the IPAddress it in the `Docker Cloud Details` > `Docker Host URI` of the cloud you just created, in the format: `tcp://<ip>:2375`.
         - Note: To run agent with Jenkins, use the local IP of `127.0.0.1`.
    3. Check `Enabled` and Save.
    4. Go to the the cloud you just created, click `Configure` > `Docker Agent Templates`, `Create`.
        - `Labels` - Used to tell Jenkins which agents to use for the build
        - `"Enabled"` - Check it
        - `Name` - Just a name
        - `Docker Image` - agent image to use, can try `jenkins/agent:alpine-jdk11`, use a template needed by your use case
            - You can create your own agent as well, e.g. python:
            ```Dockerfile
            FROM jenkins/agent:alpine-jdk11
            USER root
            RUN apk add python3
            RUN apk add py3-pip
            USER jenkins
            ```
        - `Instance Capacity` - Recommended is 2
        - `Remote file system root` - /home/jenkins
        - Everything else default.

5. Using the Agent
   1. In your Job's Configure, `General Settings > Restrict where this project can be run`
   2. Enter the label of the agent you just created
in your job's configure

## Deployment / Jenkinsfile Example
1. Install git plugin on Jenkins
2. Go add your git credentials in Manage Jenkins > Manage Credentials
```groovy
pipeline {
   agent any

   environment {
      DOCKER_USER = ''
      DOCKER_IMAGE = 'image:${BUILD_NUMBER}' //using build number for image tag

      GITLAB_URL = '' //without https
      GITLAB_BRANCH = 'main'
      GITLAB_CREDENTIALS = '${GIT_USERNAME}:${GIT_PASSWORD}' //set in jenkins
   }

   options {
      skipStagesAfterUnstable()
   }

   stages {
      stage('Clone Repository') {
         steps {
            echo 'Cloning Repository...'
            withCredentials([usernamePassword(credentialsId: 'your-credentials-id', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
               git branch: $GITLAB_BRANCH, url: 'https://$GITLAB_CREDENTIALS@$GITLAB_URL'
            }
         }
      }
      stage('Environment Setup') { // install requirements to do testing
         steps {
            sh '''
            cd ./path/to/requirements.txt
            pip install -r requirements.txt
            '''
         }
      }
      stage('Unit Testing') { // run tests here
         steps {
            echo 'Testing'
            script {
               sh './filepath/to/tests/py'
            }
         }
      }
      stage('Build') {
         steps {
            // files are removed in the dockerfile
            echo 'Building Image as $DOCKER_USER/$DOCKER_IMAGE'
            script {
               sh 'docker build -t $DOCKER_IMAGE .'
            }
         }
      }
      stage('Push to Docker Hub') {
         steps {
            script {
               sh 'docker push $DOCKER_USER/$DOCKER_IMAGE'
            }
         }
      }
      stage('Deploy - Staging') {
         steps {
            echo 'Deploying'
         }
      }
      stage('Deploy - Production') {
         steps {
            echo 'Deploying'
         }
      }
   }

   post {
      always {
         // clean up
         sh 'docker rmi $DOCKER_IMAGE || true'
      }
   }
}

```

Agent with Docker:
```Dockerfile
FROM jenkins/inbound-agent:latest

USER root
RUN apt-get update && apt-get install -y docker.io
USER jenkins
```

Python Agents
```Dockerfile
FROM jenkins/agent:alpine-jdk11
USER root
RUN apk add python3
RUN apk add py3-pip
USER jenkins
```