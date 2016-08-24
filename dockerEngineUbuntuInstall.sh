#!/bin/bash
#https://docs.docker.com/engine/installation/linux/ubuntulinux/
#See if kernel is valid
kArrayCurr=($(uname -r | awk -F 'generic' '{print $1}' | sed 's/-/./g' | sed 's/.$//g' | sed 's/\./ /g'))
kArrayReq=(3 11 0 15)
proceedKernel=0
tmpF="tmpFile"

for((i=0;i<${#kArrayReq[*]};i++))
{
	if (( "${kArrayCurr[$i]}" -ge "${kArrayKer[$i]}" ))
	then
		echo "Valid kernel"
		proceedKernel=1 
		break;
	fi
}
if [ "${proceedKernel}" == "1" ]
then
	
	#update
	sudo apt-get update
	sudo apt-get install apt-transport-https ca-certificates
	sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	dockerFile="/etc/apt/sources.list.d/docker.list"
	uRelease=$(lsb_release -a )
	
	uVers=("Ubuntu_Precise_12.04" "Ubuntu_Trusty_14.04" "Ubuntu_Wily_15.10" "Ubuntu_Xenial_16.04")
	uDebs=("deb_https://apt.dockerproject.org/repo_ubuntu-precise_main" "deb_https://apt.dockerproject.org/repo_ubuntu-trusty_main" "deb_https://apt.dockerproject.org/repo_ubuntu-wily_main" "deb_https://apt.dockerproject.org/repo_ubuntu-xenial_main")
	for((i=0;i<${#uVers[*]};i++))
	{
		foundR=0
		mathF=1
		for uVerParts in $(echo "${uVers[$i]}" | sed 's/_/ /g')
		do
			uR_uV=$(echo "${uRelease}" | tr '\n' ' ' | grep -i "${uVerParts}" | wc -l)
			mathF=$(( ${uR_uV} * ${mathF} ))
		done
		if [[ "${mathF}" == "1" ]]
		then
			foundR=1
			echo "${uVers[$i]} found" | sed 's/_/ /g'
			if [ -f "${dockerFile}" ]
			then
				sudo rm "${dockerFile}"
				sudo touch "${dockerFile}"  
				echo "${uDebs[$i]}" | sed 's/_/ /g' | sed 's/$/\n/g' > "${tmpF}"
				sudo cp "${tmpF}" "${dockerFile}"
				rm "${tmpF}"
			else
				sudo touch "${dockerFile}"
				echo "${uDebs[$i]}" | sed 's/_/ /g' | sed 's/$/\n/g' > "${tmpF}"
				sudo cp "${tmpF}" "${dockerFile}"
				rm "${tmpF}"
			fi
		fi
	}
	if [ "${foundR}" == "1" ]
	then
		sudo apt-get update
		sudo apt-get purge lxc-docker
		apt-cache policy docker-engine
	fi	
fi
