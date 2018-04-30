#! /bin/bash
cd `pwd`
rm config.xml

echo "Git url is: $1"
echo "Job Branch is: $2"
echo "Microservice name is: $3"
echo "Jenkins job name is: $4"
echo "Jenkins job template id is: $5"
echo "Jira Story id is: $6"

if [ $5 = "98" ]; then
		mkdir temp
		cp pipeline/checkout_config_template.xml temp/
		cp pipeline/build_config_template.xml temp/
		cp pipeline/analysis_template.xml temp/
		cp pipeline/artifact_upload_config.xml temp/

		sed -i "s,template.git.url,$1,g" temp/checkout_config_template.xml
		sed -i "s,template.branchname,$2,g" temp/checkout_config_template.xml
		sed -i "s,template.servicename,$3,g" temp/build_config_template.xml
		sed -i "s,template.servicename,$3,g" temp/analysis_template.xml
		sed -i "s,template.servicename,$3,g" temp/artifact_upload_config.xml

		java -jar jenkins-cli.jar -s http://localhost:7070 update-job Job_Checkout < temp/checkout_config_template.xml
		java -jar jenkins-cli.jar -s http://localhost:7070 update-job Job_code_analysis < temp/analysis_template.xml
		java -jar jenkins-cli.jar -s http://localhost:7070 update-job Job_build_services < temp/build_config_template.xml
		java -jar jenkins-cli.jar -s http://localhost:7070 update-job Job_artifact_upload < temp/artifact_upload_config.xml
		
else
	cp jenkins_template_$5.xml config.xml

	sed -i "s,template.git.url,$1,g" config.xml
	sed -i "s,template.branchname,$2,g" config.xml
	sed -i "s,template.servicename,$3,g" config.xml
	sed -i "s,template.jobname,$4,g" config.xml
	sed -i "s,template.jobname,$6,g" config.xml

	java -jar jenkins-cli.jar -s "http://localhost:7070" create-job $4 < config.xml		
fi

