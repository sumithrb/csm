pipeline {
  agent { label "metal-gcp-builder" }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timestamps()
  }

  stages {
    stage('Setup Tools'){
      steps {
        sh "./validate_docker_manifests.sh install_tools"
      }
    }

    stage('Validate') {
      parallel {
        stage('Helm'){
          steps {
            sh "./validate_docker_manifests.sh validate_helm"
          }
        }

        stage('RPM Index'){
          steps {
            sh "./validate_docker_manifests.sh validate_rpm_index"
          }
        }

        stage('Containers'){
          steps {
            sh "./validate_docker_manifests.sh validate_containers"
          }
        }

        stage('Helm Versions'){
          steps {
            sh "./validate_docker_manifests.sh validate_manifest_versions"
          }
        }

        stage('Helm Images'){
          steps {
            sh "./validate_docker_manifests.sh update_helmrepo"
            sh "./validate_docker_manifests.sh validate_helm_images"
          }
        }
      }
    }
  }
}
