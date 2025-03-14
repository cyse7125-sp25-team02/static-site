pipeline {
    agent any
    
    environment {
        GITHUB_CREDENTIALS = credentials('github-credentials')
    }
    
    stages {
        stage('Prepare Workspace') {
            steps {
                cleanWs()
                sh 'git config --global user.email "jenkins@jkops.com"'
                sh 'git config --global user.name "Jenkins"'
            }
        }
        
        stage('Checkout') {
            steps {
                script {
                    // Checkout the PR branch
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "${env.CHANGE_BRANCH ?: env.GIT_BRANCH}"]],
                        extensions: [
                            [$class: 'CleanBeforeCheckout'],
                            [$class: 'PruneStaleBranch']
                        ],
                        userRemoteConfigs: [[
                            credentialsId: 'github-credentials',
                            url: 'https://github.com/cyse7125-sp25-team02/static-site',
                            refspec: '+refs/pull/*:refs/remotes/origin/pr/* +refs/heads/*:refs/remotes/origin/*'
                        ]]
                    ])
                }
            }
        }
        
        stage('Verify Conventional Commits') {
            steps {
                script {
                    // Get the base branch (usually main/master)
                    def baseBranch = env.CHANGE_TARGET ?: 'master'
                    
                    // Get all commits in this PR
                    sh "git fetch origin ${baseBranch}:refs/remotes/origin/${baseBranch}"
                    
                    // Get all commit messages since branching from base branch
                    def commitMessages = sh(
                        script: "git log origin/${baseBranch}..HEAD --pretty=format:'%s'",
                        returnStdout: true
                    ).trim()
                    
                    echo "Checking commit messages for conventional commit format"
                    
                    // Define the conventional commit pattern
                    // Format: type(scope): description
                    def conventionalCommitPattern = /^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?: .+$/
                    
                    def invalidCommits = []
                    commitMessages.split('\n').each { commit ->
                        if (commit && !commit.matches(conventionalCommitPattern)) {
                            invalidCommits.add(commit)
                        }
                    }
                    
                    if (invalidCommits.size() > 0) {
                        echo "The following commits do not follow the conventional commit format:"
                        invalidCommits.each { commit ->
                            echo "- ${commit}"
                        }
                        error "PR contains commits that do not follow conventional commit format. Please fix and try again."
                    } else {
                        echo "All commits follow the conventional commit format!"
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo "All commits follow conventional commit format"
        }
        failure {
            echo "Some commits do not follow conventional commit format"
        }
    }
}
