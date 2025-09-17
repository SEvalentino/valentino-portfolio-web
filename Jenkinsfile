pipeline {
  agent any
  parameters {
    choice(name: 'RELEASE_NAME', choices: ['portfolio-landing', 'portfolio-appdb'], description: 'Pilih release helm untuk deploy')
    choice(name: 'VALUES_FILE', choices: ['values-landing.yaml', 'values-appdb.yaml'], description: 'Pilih values file untuk helm deploy')
  }
  environment {
    PROJECT_ID   = 'valentino-project-471103'
    REGION       = 'asia-southeast1'
    AR_REPO      = 'portfolio-repo'
    IMAGE_NAME   = 'valentino-portfolio'
    IMAGE_URI    = "asia-southeast1-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/${IMAGE_NAME}"
    CLUSTER      = 'portfolio-cluster'
    ZONE         = 'asia-southeast1-a'
    K8S_NAMESPACE= 'portfolio'
    SONARQUBE_ENV= 'sonarqube'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv("${SONARQUBE_ENV}") {
          withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
            script {
              def scannerHome = tool 'sonar-scanner'
              sh """
                ${scannerHome}/bin/sonar-scanner \
                  -Dsonar.login=${SONAR_TOKEN}
              """
            }
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 2, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        withCredentials([file(credentialsId: 'gcp-sa-jenkins', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
          sh '''
            gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
            gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

            TAG=$(date +%Y%m%d%H%M%S)
            echo $TAG > .image_tag

            docker build -t ${IMAGE_URI}:$TAG .
            docker push ${IMAGE_URI}:$TAG
          '''
        }
      }
    }

    stage('Deploy (Helm)') {
      steps {
        withCredentials([file(credentialsId: 'gcp-sa-jenkins', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
          sh '''
            gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
            gcloud container clusters get-credentials ${CLUSTER} --zone ${ZONE} --project ${PROJECT_ID}

            TAG=$(cat .image_tag)
            helm upgrade --install ${RELEASE_NAME} ./portfolio-chart \
              -n ${K8S_NAMESPACE} \
              -f ./portfolio-chart/${VALUES_FILE} \
              --set image.repository=${IMAGE_URI} \
              --set image.tag=$TAG

            kubectl -n ${K8S_NAMESPACE} rollout status deployment/${RELEASE_NAME} --timeout=180s
          '''
        }
      }
    }
  }
}

