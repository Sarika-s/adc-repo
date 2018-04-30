#! /bin/bash

# Display help for the script.
if [ "$#" -lt 3  ]
then
	echo "Invalid inputs to the script."
	echo " "
	echo " "
	echo "*********************************************"
	echo "Help Usage syntex."
	echo " "
	echo "Format for comamnd."
	echo "	./jenkins_jobs.sh key#value ...n Send n number of key and value pair seprated by #"
	echo " "
	echo "Example for command."
	echo '	./jenkins_jobs.sh jobtemplateid#"templateid" jobname#"Jenkins Job Name" jobjenkinsurl#"https://jenkinshostname:8080" jobjenkinstype#create-job  jobjenkinsusername#username  jobjenkinspassword#password replacement_key#replacement_value ..... '
	echo "*********************************************"
	exit 1
fi

# Does the cleanup of the old config file if exisits.
cd `pwd`
oldConfigFile="config.xml"
if [ -f "$oldConfigFile" ]
then
	echo "Old config file Found. Cleaning it up now."
	rm config.xml
else
	echo "Old config file not found. So no cleanup is required"
fi

# Check for job templete file exisits or not.
for arg; do
	pair="$arg"

	OLDIFS=$IFS
	IFS="#"
	read -a array <<< "$(printf "%s" "$pair")"
	IFS=$OLDIFS

	if [ ${array[0]} = "jobtemplateid" ]
	then
		jobtemplatefileid=${array[1]}
	fi

done

#jobtemplatefileid=${array[1]}
jobtemplatefile="job_templates/jenkins_template_$jobtemplatefileid.xml"
echo "Job templete file name: $jobtemplatefile"

if [ -f "$jobtemplatefile" ]
then
	cp $jobtemplatefile config.xml
else
	echo "Template file does not existis, exiting from script"
	exit 1
fi

for arg; do
	pair="$arg"

	OLDIFS=$IFS
	IFS="#"
	read -a array <<< "$(printf "%s" "$pair")"
	IFS=$OLDIFS

	key=${array[0]}
	value=${array[1]}

	if [ $key = "jobname" ]
	then
		jobname=$value
		echo "Setting up the job name as $jobname"
	elif [ $key = "jobjenkinsuser" ]
	then
		jobjenkinsuser=$value
		echo "Setting up the job jenkins user as $jobjenkinsuser"
	elif [ $key = "jobjenkinspassword" ]
	then
		jobjenkinspassword=$value
		echo "Setting up the job jenkins password as $jobjenkinspassword"
	elif [ $key = "jobjenkinsurl" ]
	then
		jobjenkinsurl=$value
		echo "Setting up the job jenkins url as $jobjenkinsurl"
	elif [ $key = "jobjenkinstype" ]
	then
		jobjenkinstype=$value
		echo "Setting up the job jenkins type as $jobjenkinstype"
	else
		echo "Replacing $key with: $value in config file."
		sed -i "s,$key,$value,g" config.xml
	fi

done

echo  "executing java -jar jenkins-cli.jar -s $jobjenkinsurl $jobjenkinstype $jobname --username $jobjenkinsuser --password $jobjenkinspassword < config.xml"

java -jar jenkins-cli.jar -s "$jobjenkinsurl" $jobjenkinstype $jobname --username $jobjenkinsuser --password $jobjenkinspassword < config.xml
