pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    triggers {
         pollSCM('* * * * *')
     }
  
    stages {

//  Checkout Git Repository

        stage("Git Checkout - Development"){
            when { branch 'development' }
            steps {
                checkout scm
                }
        }
        stage("Git Checkout - Staging"){
            when { branch 'staging' }
            steps {
                checkout scm
                }
        }
        stage("Git Checkout - Production"){
            when { branch 'master' }
            steps {
                checkout scm
                }
        } 

//  Build War file

        stage("Build War - Development"){
            when { branch 'development' }
            steps{
                sh '''#!/usr/bin/env bash
                    cd sample-app
                    java -cvf sample.war *
                '''
            }
        }
        stage("Build Image - Staging"){
            when { branch 'staging' }
            steps{
                sh '''#!/usr/bin/env bash
                    cd sample-app
                    java -cvf sample.war *
                '''
            }
        }
        stage("Build Image  - Production "){
            when { branch 'master' }
            steps{
                sh '''#!/usr/bin/env bash
                    cd sample-app
                    java -cvf sample.war *
                '''
            }
        } 



//  Deploy war file to Webserver

        stage("Deploy War - Development"){
            when { branch 'development' }
            steps{
                sh '''#!/usr/bin/env bash
                    scp -o StrictHostKeyChecking=no sample-app/sample.war ubuntu@10.0.28.8:/var/lib/tomcat9/webapps/
                    ssh -o StrictHostKeyChecking=no ubuntu@10.0.28.8 <<-'ENDSSH'
                    sudo systemctl restart tomcat9
                    ENDSSH
                '''
            }
        }
        stage("Deploy Image - Staging"){
            when { branch 'staging' }
             steps{
                sh '''#!/usr/bin/env bash
                    scp -o StrictHostKeyChecking=no sample-app/sample.war ubuntu@10.0.28.8:/var/lib/tomcat9/webapps/
                    ssh -o StrictHostKeyChecking=no ubuntu@10.0.28.8 <<-'ENDSSH'
                    sudo systemctl restart tomcat9
                    ENDSSH
                '''
            }
        }
        stage("Deploy Image - Production "){
            when { branch 'master' }
            options {
                timeout(time: 10, unit: 'MINUTES')
            }

            
             steps{
                input message: "Press Proceed to continue deployment", submitter:"jenkinsadmin,pinmicroadmin"
                sh '''#!/usr/bin/env bash
                    scp -o StrictHostKeyChecking=no sample-app/sample.war ubuntu@10.0.28.8:/var/lib/tomcat9/webapps/
                    ssh -o StrictHostKeyChecking=no ubuntu@10.0.28.8 <<-'ENDSSH'
                    sudo systemctl restart tomcat9
                    ENDSSH
                '''
                           
                
            } 
        } 

    }  
            


    post {

        always {
           // Wipe out the workspace before we finish!
            deleteDir()
            cleanWs()
        

        }
        success {
            // Wipe out the workspace before we finish!
            deleteDir()
            cleanWs()
            // Send Success Message to Team
        }
        failure {
            echo "Build failed"
            deleteDir()
            cleanWs()
            // Send Failure Message to Team                
        }
    }

}        

