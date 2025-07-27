pipeline {
    agent {
        docker {
            image 'maven:3.8.8-openjdk-17'
            args '-v $HOME/.m2:/root/.m2'
        }
    }

    environment {
        APP_NAME = 'demoapp-0.0.1-SNAPSHOT.jar'
        REMOTE_APP_DIR = '/opt/demoapp'
        REMOTE_SERVER_IP = '192.168.1.50'
        REMOTE_SSH_USER = 'stack'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                echo 'Checking out source code from Git...'
                git credentialsId: 'github-cred', branch: 'main', url: 'https://github.com/RJyilmaz/java_app.git'
            }
        }

        stage('Build and Test') {
            steps {
                echo 'Building application with Maven and running tests...'
                sh "mvn clean install -DskipTests"
            }
        }

        stage('Deploy to Remote Server') {
            steps {
                echo "Deploying ${env.APP_NAME} to ${env.REMOTE_SERVER_IP}..."
                sshagent(credentials: ['your-ssh-credentials-id']) {
                    sh "scp target/${env.APP_NAME} ${env.REMOTE_SSH_USER}@${env.REMOTE_SERVER_IP}:${env.REMOTE_APP_DIR}/"
                    sh "ssh -o StrictHostKeyChecking=no ${env.REMOTE_SSH_USER}@${env.REMOTE_SERVER_IP} 'chmod +x ${env.REMOTE_APP_DIR}/startup.sh && bash ${env.REMOTE_APP_DIR}/startup.sh'"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline succeeded! Application deployed.'
        }
        failure {
            echo 'Pipeline failed! Check logs for errors.'
        }
    }
}
