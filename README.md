# Spring Boot CI/CD Pipeline with Jenkins and Docker

This project demonstrates a Continuous Integration/Continuous Deployment (CI/CD) pipeline for a Spring Boot application using Jenkins and Docker.

## Project Components:

* **Spring Boot Application**
* **Jenkins**
* **Docker**
* **Git**
* **Remote Server**

## CI/CD Workflow:

1. Code commit to Git repository.
2. Jenkins trigger via webhook or polling.
3. Build with `maven:3.8.8-openjdk-17` image.
4. Deploy JAR via SCP.
5. Execute `startup.sh` on the remote server.

## Setup Instructions:

1. Clone this repo.
2. Setup the remote server with Java and create `/opt/demoapp`.
3. Install Jenkins, necessary plugins, and credentials.
4. Configure pipeline job with this repo and Jenkinsfile.
