pipeline {
    agent any

    stages {
            stage('Database') {
                steps {
                    echo 'This is for Database and Schema change'
                }
            }

            stage('git-check') {
                steps {
                    checkout( //app
                        [$class: 'GitSCM', 
                        branches: [[name: '*/$app_branch']], 
                        extensions: [ [$class: 'RelativeTargetDirectory', relativeTargetDir: 'approot']], 
                        userRemoteConfigs: [[credentialsId: 'e9f69cd8-69af-4b59-b6a5-e7fbeee3fcf3', url: 'https://gitlab.com/IndeezDevAdmin/indeez-poc']]]
                    )
               
                    // checkout(  //api
                    //     [$class: 'GitSCM', 
                    //     branches: [[name: '*/$api_branch']], 
                    //     extensions: [ [$class: 'RelativeTargetDirectory', relativeTargetDir: 'apiroot']], 
                    //     userRemoteConfigs: [[credentialsId: 'e9f69cd8-69af-4b59-b6a5-e7fbeee3fcf3', url: 'https://gitlab.com/IndeezDevAdmin/indeez_lambda']]]
                    // )
                }
            }

            stage('build-backend') {
                when { anyOf {
                expression { runonly == 'backend'}
                expression { runonly == 'both'}
            }    }       
                steps {

                    // echo 'build-backend - ${WORKSPACE}'

                    // build ( 
                            
                            //Backend build
                            dir("${WORKSPACE}")
                            {
                                sh "pwd"
                                sh "chmod +x -R ${WORKSPACE}"
                                sh "./deploy.sh"
                            }
                    // ) 

                }
            }

            stage('build-frontend') {
                when {anyOf {
                expression { runonly == 'frontend'}
                expression { runonly == 'both'}
            } }
                steps {

                    // echo 'build-frontend - ${WORKSPACE}'    
                    // build (
                            
                    //Frontend build
                    dir("${WORKSPACE}/approot")
                    {
                        sh "chmod +x -R ${WORKSPACE}/approot"
                        sh "./deploy.sh"
                        sh "pwd"

                        //sh "aws s3 cp ${WORKSPACE}/approot/dist/admin/ s3://$stage-admin.indeez/ --recursive"
                        script {
                            def returCode = sh(script: "aws cloudformation deploy --stack-name $stage-$ev-app --template-file ${WORKSPACE}/approot/frontend.yml --parameter-overrides StageName=$stage AlternateDomainNames1=$stage-$ev-admin.indeez.me AlternateDomainNames2=$stage-$ev-customer.indeez.me  AlternateDomainNames3=$stage-$ev-partner.indeez.me AlternateDomainNames4=$stage-$ev-tpa.indeez.me  AlternateDomainNames5=$stage-$ev-tpl.indeez.me DomainName=$DomainName  --capabilities CAPABILITY_NAMED_IAM", returnStatus: true)
                            if (returCode != 1) 
                            { 
                                sh "echo 'exit code: (255)'"
                                sh "echo 'Copying Admin app to s3 bucket'"
                                sh "aws s3 cp ${WORKSPACE}/approot/dist/admin/ s3://$stage-admin.indeez/ --recursive"
                                sh "echo 'Copying Customer app to s3 bucket'"
                                sh "aws s3 cp ${WORKSPACE}/approot/dist/customer/ s3://$stage-customer.indeez/ --recursive"
                                sh "echo 'Copying TPA app to s3 bucket'"
                                sh "aws s3 cp ${WORKSPACE}/approot/dist/tpa/ s3://$stage-tpa.indeez/ --recursive"
                                sh "echo 'Copying TPL app to s3 bucket'"
                                sh "aws s3 cp ${WORKSPACE}/approot/dist/tpl/ s3://$stage-tpl.indeez/ --recursive"
                                sh "echo 'Copying Partner app to s3 bucket'"
                                sh "aws s3 cp ${WORKSPACE}/approot/dist/partner/ s3://$stage-partner.indeez/ --recursive"                                                                                                
                            } 
                        }
                    }
                        // )
                }
            }
        
            // stage('Copy s3 files') {
            //     steps {
                    // sh 'start=$(date +%s)'
                    // sh 'echo $start'
                    // sh 'echo "Sleeping...."'
                    
                    // # do something
                    // sh 'sleep 60'
                
                    // sh 'end=$(date +%s)'
                    // sh 'echo $end'
                    // sh 'echo "Sleeping....Ended"'

                    // dir("${WORKSPACE}/approot")
                    // {
                    //     sh "aws s3 cp ${WORKSPACE}/approot/dist/admin/ s3://$stage-admin.indeez/ --recursive"
                    // }
            //     }
            // }

            stage('Customer') {
                steps {
                    echo 'This is for Customer persona'
                }
            }
            stage('Partner') {
                steps {
                    echo 'This is for Partner persona'
                }
            }
            stage('TPA') {
                steps {
                    echo 'This is for TPA persona'
                }
            }
            stage('TPL') {
                steps {
                    echo 'This is for TPL persona'
                }
            }
        }
}
