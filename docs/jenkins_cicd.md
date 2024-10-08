GitLab Push/MR -> GitLab Checking before Build -> Jenkins Build -> Jenkins Testing -> Deployment

Stage 2: Syntax checking etc.
Stage 3: Trigger jenkins build
update status in gitlab

Stage 4: Trigger jenkins build testing
update status in gitlab

Stage 5: Deployment

| | Table of Contents |
|:-:|:-:|
|1| [Running Jenkins as Docker Container](#running-jenkins-as-a-docker-container) |
|2| [Creating Jobs in Jenkins](#jobs-in-jenkins) |
|3| [Agents](#agents) |
|4| [Custom Agents](#creating-custom-agents) |
|5| [Deployment / Jenkinsfile example](#deployment--jenkinsfile-example) |
|6| [Configuring GitLab with Jenkins](#integrating-gitlab-with-jenkins) |
|7| [Securing Jenkins & Reverse Proxy / localhost Forwarding](#securing-jenkins--reverse-proxy--localhost-forwarding) |


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
   1. First create a container running the alpine socat image, acts as a proxy from the local jenkins container to the agent, forwards the traffic from Jenkins to the Docker Desktop container on the host machine.
      - If running jenkins as a container, the docker host uri field needs to be entered with the unix/tcp address of the docker host. But since jenkins is being run as a container, container can't reach the docker host unix port.
      - So another container is created to mediate between docker host and jenkins container, publishing the docker host's unix port as its tcp port.
      - after creation, can go back to the docker configuration in jenkins and enter `tcp://socat-container-ip:2375`

    ```powershell
    docker run -d --restart=always -p 127.0.0.1:<port>:2375 --network jenkins -v /var/run/docker.sock:/var/run/docker.sock alpine/socat tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock
    ```

    2. To connect to the proxy container: find the `IPAddress` under `Networks > Jenkins > IPAdress`, after running the command `docker inspect <container_id> | grep IPAddress`, then enter the IPAddress it in the `Docker Cloud Details` > `Docker Host URI` of the cloud you just created, in the format: `tcp://<ip>:2375`.
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

## Creating Custom Agents

1. Create an Image containing the agent using `docker build -f <docker/filepat> -t <image_name> .`
2. Upload into docker hub for usage

Note: Get the base image as needed by use case.

Example Agents:
```Dockerfile
# Docker agents for image building
FROM jenkins/inbound-agent:latest
USER root
RUN apt-get update && apt-get install -y docker.io
USER jenkins
```

```Dockerfile
## Python agents to run python scripts
FROM jenkins/agent:alpine-jdk21
USER root
RUN apk add python3
RUN apk add py3-pip
USER jenkins
```

```Dockerfile
## To run cppcheck
FROM gcc:latest
USER root
RUN apt-get update && apt-get install -y cppcheck clang-tidy
USER jenkins
```

## Deployment / Jenkinsfile Example
1. Install git plugin on Jenkins
2. Go add your git credentials in Manage Jenkins > Manage Credentials
```groovy
pipeline {
   agent none

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
      stage('Code Syntax Checking (using Cppcheck)') {
         agent { label '' }
         steps {
            script {
               sh 'cppcheck --enable=all --inconclusive'
               sh 'cppcheck filepath'
            }
         }
      }
      stage('Unit Testing') { // run tests here
         agent { label 'name' }
         steps {
            echo 'Testing'
            script {
               sh './filepath/to/tests/py'
            }
         }
      }
      stage('Build') {
         steps {
            // use this line to update status on github
            updateGitlabCommitStatus name: 'build', state: 'pending'
            // files are removed in the dockerfile
            echo 'Building Image as $DOCKER_USER/$DOCKER_IMAGE'
            script {
               sh 'docker build -t $DOCKER_IMAGE .'
            }
            updateGitlabCommitStatus name: 'build', state: 'success'
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

## Integrating GitLab with Jenkins
https://plugins.jenkins.io/gitlab-plugin/
https://docs.gitlab.com/ee/integration/jenkins.html

1. Install the GitLab plugin on Jenkins.
2. Add your GitLab project to the Jenkins configuration.
   1. `Manage Jenkins > System Configuration > System`, and scroll until you find GitLab
   2. Add a connection by providing a `Connection Name`, `GitLab host URL` and `Credentials`.
      - `Connection Name` -> Name for the connection
      - `GitLab Host URL` -> Complete URL to the GitLab server e.g. https://gitlab.mydoamin.com
      - `Credentials` -> Has to be API token, select existing or create new as `GitLab API token`
        - Go to your `GitLab Profile > Preferences > Access Tokens > Create`
        - Set an `Expiration Date`, and select `api` for scopes, or enable as needed, and create.
        - Take note of API token
        - `Add Credentials` in Jenkins as `GitLab API token`, then paste in the API token, adjust other information as needed.
   3. Enable authentication for '/project' end-point
   4. Save.
3. Go to your project in Jenkins `> Configure`
   1. Under `GitLab Connection`, select the connection you just created.
   2. Under `Source Code Management`:
      1. Select `Git`.
      2. Enter the `Repository URL` e.g. `https://git.mydomain.com/something.git`.
      3. Select your `Credentials`
         - `Credentials` -> Use existing or create new under Global: `__Username with password__`, then enter information as needed.
      4. Specify any branches as needed.
   3. Under `Build Triggers`
      1. Enable `Build when a change is pushed to GitLab`, take note of the `GitLab Webhook URL`
      2. Enable triggers and settings as needed.
      3. Go to `Advanced`, enable options as needed.
      4. At `Secret Token`, generate a new secret token and take note of it.
      5. Go to your GitLab project and create a `Webhook`, enter the `Webhook URL` provided earlier, as well as the `Secret Token`, and enable triggers as needed.
      6. Save.

## Securing Jenkins & [Reverse Proxy](#reverse-proxy-using-nginx) / [localhost forwarding](#localhost-forwarding-using-localtunnel)

By default, if Jenkins is set up on a local host, Jenkins will not be reachable if requests are sent to it. Therefore, a `reverse proxy` will need to be set up.
   - `Reverse Proxy` is a server that sits between client devices and web servers, forwarding client requests to the web server then returning the server's response back to the clients.

(Incomplete Section)
### Reverse Proxy using Nginx (Safer)
1. Install Nginx using `sudo apt update` and `sudo apt install nginx`
2. Start Nginx using `sudo systemctl start nginx`
3. Enable Nginx using `sudo systemctl enable nginx`
4. Create a configuration file for the Jenkins site using `sudo nano /etc/nginx/sites-available/jenkins`
5. Enter the following configuration:
   ```
   upstream jenkins {
      keepalive 32; # keepalive connections
      server 127.0.0.1:8080; # jenkins ip and port
   }

   # Required for Jenkins websocket agents
   map $http_upgrade $connection_upgrade {
      default upgrade;
      '' close;
   }

   server {
      listen          80;       # Listen on port 80 for IPv4 requests

      server_name     jenkins.example.com;  # replace 'jenkins.example.com' with your server domain name

      # this is the jenkins web root directory
      # (mentioned in the output of "systemctl cat jenkins")
      root            /var/run/jenkins/war/;

      access_log      /var/log/nginx/jenkins.access.log;
      error_log       /var/log/nginx/jenkins.error.log;

      # pass through headers from Jenkins that Nginx considers invalid
      ignore_invalid_headers off;

      location ~ "^/static/[0-9a-fA-F]{8}\/(.*)$" {
         # rewrite all static files into requests to the root
         # E.g /static/12345678/css/something.css will become /css/something.css
         rewrite "^/static/[0-9a-fA-F]{8}\/(.*)" /$1 last;
      }

      location /userContent {
         # have nginx handle all the static requests to userContent folder
         # note : This is the $JENKINS_HOME dir
         root /var/lib/jenkins/;
         if (!-f $request_filename){
            # this file does not exist, might be a directory or a /**view** url
            rewrite (.*) /$1 last;
            break;
         }
         sendfile on;
      }

      location / {
         sendfile off;
         proxy_pass         http://jenkins;
         proxy_redirect     default;
         proxy_http_version 1.1;

         # Required for Jenkins websocket agents
         proxy_set_header   Connection        $connection_upgrade;
         proxy_set_header   Upgrade           $http_upgrade;

         proxy_set_header   Host              $http_host;
         proxy_set_header   X-Real-IP         $remote_addr;
         proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Proto $scheme;
         proxy_max_temp_file_size 0;

         #this is the maximum upload size
         client_max_body_size       10m;
         client_body_buffer_size    128k;

         proxy_connect_timeout      90;
         proxy_send_timeout         90;
         proxy_read_timeout         90;
         proxy_request_buffering    off; # Required for HTTP CLI commands
      }
   }

   ```
6. Create a symlink to enable the configuration: `sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/`
7. Test the configuration using `sudo nginx -t`
8. Restart nginx using `sudo systemctl restart nginx`
9. Ensure firewall allows inbound traffic on ports `80 (HTTP)` and `443 (HTTPS)`, `sudo ufw allow 'Nginx Full`

(Optional SSL)
9. Install Certbot: `sudo apt install certbot python3-certbot-nginx`
10. Obtain an SSL certificate using `sudo certbot --nginx -d your_domain.com`
11. As Certbot sets up a cron job for automatic renewal, you can test renewal with `sudo certbot renew --dry-run`
12. You can now access with either `http://your-domain.com` or `https://your-domain.com` if you have SSL.

### localhost forwarding using LocalTunnel (Less Safer)
1. Install localtunnel using node.js: `npm install -g localtunnel`
2. Run localtunnel listening to a port using `lt --port 8080`, assuming Jenkins is running locally on port 8080
3. To get custom subdomain: use `lt --port 8080 --subdomain custom_subdomain`