
function Get-SiteDeployed
{

    Param(
	[string] $Machinename,
	[string] $Username,
	[string] $Password,
	[string] $ApplicationName, 
	[string] $ProjectName
	)

		# MSDeploy path
        $msDeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe"
		# IIS app command path
		$iisCmd = "C:\Windows\System32\inetsrv\appcmd.exe"
        
        $ProjectName = "Consumer"
        $MachineName = '"localhost"' # '"http://localhost:59989/MsDeploy.axd"'
       	$ApplicationName = "TestProvisioning"
        $AppPoolName = '"TestProvisioning"'
        $aclsFlag = '"true"'
        $solutionPath = (Get-Item -path ".\" -Verbose)
        
       
        write-host "********** Creating publish package *****************"

        # Publishing the packages
        dotnet publish  "$solutionPath\$ProjectName\$ProjectName.sln" -f  netcoreapp2.0 -c Release --output:"$solutionPath\Publish"

		write-host "********** Creating Site in IIS server *****************"
		# Creating a new site
		Start-Process $iisCmd " add site /name:$ApplicationName /id:10 /bindings:http/*:9000: /physicalPath:D:\$ApplicationName" -NoNewWindow -RedirectStandardError "Error.txt" -Wait
		
		sleep -seconds 1
        write-host "***************** Creating app pool *****************"
		# Create new Application pool
		Start-Process $iisCmd " add apppool /name:$AppPoolName /managedRuntimeVersion:"""" /managedPipelineMode:Integrated" -NoNewWindow -RedirectStandardError "Error.txt" -Wait
							
		sleep -seconds 1
		
		# Start-Process $iisCmd "set apppool $ApplicationName/ /applicationPool:$ApplicationName"
		write-host "***************** Mapping site to new AppPool *****************"
        
		Start-Process $iisCmd " set site /site.name:$ApplicationName /[path='/'].applicationPool:$AppPoolName" -NoNewWindow -RedirectStandardError "Error.txt" -Wait
        
		sleep -seconds 1
		
		write-host "********** Stoping IIS server *****************"
        # Stopping iis server before deployment
        IISReset /Stop

        #"C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe" '-verb:sync -source:dirPath="$solutionPath\Publish" -dest:dirPath="C:\Consumer",ComputerName="localhost",includeAcls="true",username="satyaban.m",password="Jabra@2018" -enableRule:DoNotDeleteRule -disableLink:AppPoolExtension -disableLink:ContentExtension -allowUntrusted'

		write-host "********** Creating Deployment arguments *****************"
        # Preparing Deployment argument
        $deployArgs = @("–verb:sync -source:iisApp=$solutionPath\Publish -dest:iisapp=$ApplicationName," +
        "ComputerName=$machineName" + ",includeAcls=$aclsFlag" + ",authtype='NTLM'",  
        "-enableRule:DoNotDeleteRule" ,
        "-disableLink:AppPoolExtension", 
        "-disableLink:ContentExtension", 
        "-allowUntrusted")
            
        write-host "********** Deploying package *****************"   
         # Triggering Deployment process        
        Start-Process $msDeploy -NoNewWindow -ArgumentList $deployArgs -RedirectStandardError "Error.txt" #-RedirectStandardError "Error.txt" -RedirectStandardOutput $logfile -Wait

        write-host "********** Starting IIS server **************"
        # Starting iis server after deployment
        IISReset /Start


}



Get-SiteDeployed -Machinename " " -Username " " -Password " " -ApplicationName " "  -ProjectName = "Consumer"