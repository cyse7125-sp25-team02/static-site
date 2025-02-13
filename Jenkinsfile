pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'karanthakkar09'
        DOCKER_IMAGE = 'jkops'
        DOCKER_CREDENTIALS = credentials('docker-creds')
        VERSION = '1.0.0'
    }

    triggers {
        githubPullRequest(
            cron: 'H/5 * * * *',
            triggerPhrase: '.*[Pp]lease [Bb]uild.*',
            onlyTriggerPhrase: false,
            useGitHubHooks: true,
            permitAll: false,
            autoCloseFailedPullRequests: false,
            displayBuildErrorsOnDownstreamBuilds: true
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
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
