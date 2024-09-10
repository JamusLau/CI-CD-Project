# CI/CD Timeline
| DATE | TASK | STAGE |
|:------:|:------:|:-------:|
| [September 1st - September 30th](#september-1st---september-30th) | Dev + Source Stage | CI |
| [October 1st - October 15th](#october-1st---october-15th) | Build Stage | CI |
| [October 16th - October 31st](#october-16th---october-31st) | Test Stage | CI |
| [November 1st - November 15th](#november-1st---november-15th) | Release Stage | CI |
| [November 16th >](#november-16th-) | Deployment Stage | CD |


## September 1st - September 30th
### Overview [Dev + Source Stage]
- To setup pre-commit hooks to the repo for checks before commit.
- To lint code and setup github actions for linting.
### Tasks
- [x] pre-commit hook
- [x] pre-commit hook guide
- [x] Code linting through github actions
- [x] Guide for github actions code linting
- [ ] aws keys scanner through trufflehog on github actions

## October 1st - October 15th
### Overview [Build Stage]
- To use docker to create images and do testing.

### Tasks
- [ ] Learn Docker basics
- [ ] Create container images of application
- [ ] Run unit tests within image
- [ ] Code compilation within container image
- [ ] Code coverage check - check if developers are putting in unit tests
- [ ] Create test cases

## October 16th - October 31st
### Overview [Test Stage]
- To provide ways to test intended functionality of application and do in-depth testing before delivery.
### Tasks
- [ ] Learn Docker Compose to facilitate testing
- [ ] Create test cases

## November 1st - November 15th
### Overview [Release Stage]
- To pass on the application image to environments for QA testing, production environment and staging environment.
### Tasks
- [ ] Learn Docker Hub to store images

## November 16th >
### Overview [Deployment Stage]
- Deployment of the image to various environments.
- QA testing
- Staging
- Production
### Tasks
- [ ] Create manifest to control deployment image going to environments
- [ ] Learn ArgoCD
- [ ] Create config repo
- [ ] Create environments - staging, qa, production
- [ ] Learn Prometheus
- [ ] Learn Grafana
- [ ] Setup operators using ArgoCD
- [ ] ARGO rollouts to facilitate slow deployment

# Future Plans
- Security for DevSecOps