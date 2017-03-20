## GitLab Docker Image

GitLab Docker Image with .Net Core and Mono installed.

Can be used to run cake build scripts for example

### Example

´´´
image: franklin89/gitlab-cakebuild
stages:
- build

build_job:
  stage: build
  script:
  - ./build.sh
´´´