pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'karanthakkar09'
        DOCKER_IMAGE = 'jkops'
        DOCKER_CREDENTIALS = credentials('docker-creds')
        VERSION = '1.0.0'
    }

    triggers {
        githubPullRequests {
            cron('H/5 * * * *')
            triggerPhrase('please build')
            useGitHubHooks()
            permitAll()
        }
    }

    stages {
        stage('Checkout') {
            steps {
                githubPRStatus(
                    context: 'continuous-integration/jenkins/pr-merge',
                    message: 'Starting build',
                    state: 'PENDING'
                )
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        // Set up buildx builder for multi-platform support
                        sh '''
                        docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
                        docker buildx create --name multiarch-builder --driver docker-container --use
                        docker buildx inspect --bootstrap
                    '''

                        // Build and push multi-platform image
                        sh """
                        docker buildx build \
                            --platform linux/amd64,linux/arm64 \
                            --tag ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${VERSION} \
                            --push \
                            .
                        """
                        githubPRStatus(
                            context: 'continuous-integration/jenkins/pr-merge',
                            message: 'Build successful', state: 'SUCCESS'
                            )
                    } catch (Exception e) {
                        githubPRStatus(
                            context: 'continuous-integration/jenkins/pr-merge',
                            message: 'Build failed',
                            state: 'FAILURE'
                            )
                        throw e
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
