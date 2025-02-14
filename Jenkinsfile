pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = credentials('docker-image')
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Setup BuildX') {
            steps {
                sh '''
                    docker buildx create --use
                    docker buildx inspect --bootstrap
                '''
            }
        }
        
        stage('Login and Build') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'

                sh """
                    docker buildx build --platform linux/amd64,linux/arm64 \
                    -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                    --push .
                """
            }
        }
    }
    
    post {
        always {
            node('built-in') {
                sh 'docker logout'
            }
        }
    }
}