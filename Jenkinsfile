pipeline {
  agent any
  tools {
        jdk "JDK 8"
        }
    stages {
      stage('1: Install WebGoat') {
        steps{
            script{
                echo "Download from source"
                sh 'rm -rf *'
                sh 'git clone https://github.com/WebGoat/WebGoat'
                sh 'git clone https://github.com/contraster-steve/webgoat-7.1-deploy'
                dir('./WebGoat') {
                    sh 'git checkout 7.1'
                    sh 'git switch -c 7.1-with-contrast'
                    sh "mvn clean install -Dmaven.test.skip=true"
                    }
                }
            }
        }  
      stage('2: Lessons') {
        steps{
            script{
                echo "Download the WebGoat lessons from source."
                sh 'git clone https://github.com/WebGoat/WebGoat-Lessons.git'
                dir('./WebGoat-Lessons') { 
                    sh "mvn clean install -Dmaven.test.skip=true"
                    sh "cp target/plugins/*.jar ../WebGoat/webgoat-container/src/main/webapp/plugin_lessons/"
                    }
                }
            }
        }  
      stage('3: Create YAML') {
        steps{
            withCredentials([string(credentialsId: 'AUTH_HEADER', variable: 'auth_header'), string(credentialsId: 'API_KEY', variable: 'api_key'), string(credentialsId: 'SERVICE_KEY', variable: 'service_key'), string(credentialsId: 'USER_NAME', variable: 'user_name')]) {
                script{
                    echo "Build the YAML file."
                    sh 'pwd'
                    sh 'echo "api:\n  url: https://apptwo.contrastsecurity.com/Contrast\n  api_key: ${api_key}\n  service_key: ${service_key}\n  user_name: ${user_name}\nagent:\n  java:\n    standalone_app_name: Webgoat-7.1\napplication:\n  metadata: "bU=PS", "contact=steve.smith@contrastsecurity.com"\n  session_metadata: buildNumber=${BUILD_NUMBER}, committer="Steve Smith"\nserver:\n  name: Application-Server\n  environment: qa\nAssess:\n  enable:true\nProtect:\n  enable:false" >> ./WebGoat/webgoat-standalone/target/contrast_security.yaml'
                    sh 'chmod 755 ./WebGoat/webgoat-standalone/target/contrast_security.yaml'
                }
            }
        }
      }
      stage('4: Download Agent') {
        steps{
            script{
                sh "pwd"
                sh 'curl -o ./WebGoat/webgoat-standalone/target/contrast.jar https://repo1.maven.org/maven2/com/contrastsecurity/contrast-agent/4.1.0/contrast-agent-4.1.0.jar'
            }
        }
      }     
      stage('5: Deploy') {
        steps{
            script{
            echo "Create tarball."
            sh 'cp webgoat-7.1-deploy/deploy.sh WebGoat/'
            sh 'tar -czvf WebGoat.tar.gz WebGoat/'
            echo "Copy tarball to application server."
            sh 'scp -i /home/ubuntu/steve.pem WebGoat.tar.gz ubuntu@3.136.105.63:/home/ubuntu/'
            echo "Delete existing directory."
            sh 'ssh -i /home/ubuntu/steve.pem ubuntu@3.136.105.63 sudo rm -rf /home/ubuntu/webapps/WebGoat/'
            echo "Unpack tarball."
            sh 'ssh -i /home/ubuntu/steve.pem ubuntu@3.136.105.63 sudo tar xvf /home/ubuntu/WebGoat.tar.gz'
            sh 'ssh -i /home/ubuntu/steve.pem ubuntu@3.136.105.63 sudo mv /home/ubuntu/WebGoat /home/ubuntu/webapps/WebGoat'
            echo "Deploy application."
            sh 'ssh -i /home/ubuntu/steve.pem ubuntu@3.136.105.63 sudo chmod +x /home/ubuntu/webapps/WebGoat/deploy.sh'
            sh 'ssh -i /home/ubuntu/steve.pem ubuntu@3.136.105.63 sudo sh /home/ubuntu/webapps/WebGoat/deploy.sh'
                }
            }
        }        
      stage('6: Zap!') {
        steps{
            script{
                echo "Download the Zap Docker image."
                sh 'docker pull owasp/zap2docker-stable'
                echo "Run the Zap Docker image in Headless mode."
                sh 'docker run --rm --name zap -u zap -v "$(pwd)/reports":/zap/reports/:rw -p 5150:8080 -p 5161:8090 -i owasp/zap2docker-stable zap.sh -addoninstallall -daemon -host 0.0.0.0 -config connection.timeoutInSecs=60 -config api.disablekey=true -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true </dev/null &>/dev/null &'
                sh 'docker exec zap zap-cli quick-scan -r "http://localhost:5005/WebGoat" </dev/null &>/dev/null &'
                sh 'sleep 10'
                }        
            }
        }
      stage('7: Security Gate with no JOP') {
        steps{
        contrastVerification applicationName: 'Webgoat-7.1', count: 0, profile: 'Steve TeamServer', queryBy: 4, appVersionTag: "${JOB_NAME}-${BUILD_NUMBER}", severity: 'Critical'
        }
      } 
      stage('7: Security Gate with JOP') {
        steps{
        contrastVerification applicationName: 'Webgoat-7.1', profile: 'Steve TeamServer', queryBy: 4
        }
      }      
    }
}    
