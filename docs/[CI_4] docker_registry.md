# Docker Registry
Note:
- Typical format of a tag is `repository:tag`
- Each Registry can contain multiple Repositories.
- Each Repository usually contains the same app's Image, just different versions.

## Docker Hub
1. Create a Repository on Docker Hub.
2. On GitBash, use `docker login` to login.
3. Tag your Image with the repository name: `docker tag ImageName username/repository:tag`.
4. Push onto the Repository using `docker push username/repository:tag`

Example:
   - E.g. Image name is `TestApp`, and you want to push it into `TestAppRepo`, tag the Image using `docker tag TestApp username/TestAppRepo:v1.0`.
   - Push the tagged Image into the repo using `docker push username/TestAppRepo:v1.0`
   - You can push an updated version of the Image by using the same command, just a different tag: `docker tag TestApp username/TestAppRepo:v1.1`

