#!groovy

pipeline {
    agent {
        label "${params.DEPLOY_ENV}"
    }
    environment {
        DOCKERFILE_NAME = "${params.DOCKERFILE_NAME}"
        TEAMPLATE_NAME = "${parmas.TEAMPLATE_NAME}"
        DOCKER_REGISTRY = "${params.DOCKER_REGISTRY}"
        DOCKER_REGISTRY_AUTH_ID = "${params.DOCKER_REGISTRY_AUTH_ID}"
        BUILD_NAME = "${params.BUILD_NAME}"
        RH_REGISTRY = "${params.RH_REGISTRY}"
        RH_REGISTRY_AUTH_ID = "${params.RH_REGISTRY_AUTH_ID}"
        OCP_URL = "${params.OCP_URL}"
        OCP_AUTH_ID = "${params.OCP_AUTH_ID}"
        IMAGESTREAM = "${params.IMAGESTREAM}"
        GIT_COMMIT_SHORT = sh(
            script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
            returnStdout: true
        )
    }
    
    stages {
        stage("Docker registry login") {
            steps {
                echo "=====docker login registry====="
                withCredentials([usernamePassword(credentialsId: '$DOCKER_REGISTRY_AUTH_ID', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                    docker login $RH_REGISTRY -u $USERNAME -p $PASSWORD
                    docker login $DOCKER_REGISTRY -u $USERNAME -p $PASSWORD
                    """
                }
            }
        }
        stage("Docker build image") {
            steps {
                echo "=====docker login and build====="
                sh """
                docker build -t $DOCKER_REGISTRY/$BUILD_NAME:$GIT_COMMIT_SHORT -f $DOCKERFILE_NAME .
                """
            }
        }
        stage("Docker push image") {
            steps {
                echo "=====docker login and push====="
                sh """
                docker push $DOCKER_REGISTRY/$BUILD_NAME:$GIT_COMMIT_SHORT
                """
            }
        }
        stage("ocp login") {
            steps {
                echo "=====ocp login====="
                withCredentials([string(credentialsId: '$OCP_AUTH_ID', variable: 'TOKEN')]) {
                    sh """
                    oc login $OCP_URL --token $TOKEN
                    """
                }
            }
        }
        stage("ocp init image stream and teamplate") {
            steps {
                echo "=====ocp login====="
                    sh """
                    oc apply -f $IMAGESTREAM
                    oc apply -f $TEAMPLATE_NAME
                    """
            }
        }
        stage("ocp deploy") {
            steps {
                echo "=====ocp tag new image as latest====="
                    sh """
                    oc tag $DOCKER_REGISTRY/$BUILD_NAME:$GIT_COMMIT_SHORT $BUILD_NAME:latest
                    """
            }
        }
        stage("ocp get status") {
            steps {
                echo "=====ocp get podes====="
                    sh """
                    oc get pods | grep Running 
                    """
            }
        }
    }
}
