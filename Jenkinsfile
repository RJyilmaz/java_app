pipeline {
    agent any

    environment {
        APP_NAME = 'demoapp-0.0.1-SNAPSHOT.jar'
        REMOTE_APP_DIR = '/opt/demoapp'
        DOCKER_IMAGE = 'maven:3.8.8-amazoncorretto-17'
        SSH_CREDENTIALS_ID = 'remote-ssh-cred'
        REMOTE_SERVER_IP = '192.168.1.50'  // Gerçek IP ile değiştirin
        REMOTE_SSH_USER = 'deploy-user'    // Gerçek kullanıcı ile değiştirin
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git branch: 'main', 
                     url: 'https://github.com/RJyilmaz/java_app.git'
            }
        }

        stage('Build and Test') {
            agent {
                docker {
                    image env.DOCKER_IMAGE
                    args '-v $HOME/.m2:/root/.m2 --network host'
                }
            }
            steps {
                sh 'mvn clean package'
                junit '**/target/surefire-reports/*.xml'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Deploy to Remote Server') {
            steps {
                sshagent(credentials: [env.SSH_CREDENTIALS_ID]) {
                    // Dosyaları kopyala
                    sh """
                        scp -o StrictHostKeyChecking=no \
                            target/${env.APP_NAME} \
                            startup.sh \
                            ${env.REMOTE_SSH_USER}@${env.REMOTE_SERVER_IP}:${env.REMOTE_APP_DIR}/
                    """
                    
                    // Scripti çalıştır
                    sh """
                        ssh -o StrictHostKeyChecking=no ${env.REMOTE_SSH_USER}@${env.REMOTE_SERVER_IP} \
                            "chmod +x ${env.REMOTE_APP_DIR}/startup.sh && \
                             cd ${env.REMOTE_APP_DIR} && \
                             ./startup.sh"
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            echo 'Pipeline completed.'
        }
        success {
            slackSend color: 'good', 
                      message: "SUCCESS: ${env.JOB_NAME} - Build ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend color: 'danger', 
                      message: "FAILED: ${env.JOB_NAME} - Build ${env.BUILD_NUMBER}"
            archiveArtifacts artifacts: '**/target/surefire-reports/*.txt', allowEmptyArchive: true
        }
    }
}
