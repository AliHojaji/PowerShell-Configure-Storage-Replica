#--- Author : Ali Hojaji ---#

#--*-----------------------------*--#
#---> Configure Storage Replica <---#
#--*-----------------------------*--#

#--> install storage replica feature on replication partners
Invoke-Command -ComputerName FS1-Test,FS2-Test -ScriptBlock { Install-WindowsFeature -Name Storage-Replica,FS-FileServer -IncludeManagementTools -Restart }

#--> test out a potential partnership
Test-SRTopology -SourceComputerName FS1-Test -SourceVolumeName R: -SourceLogVolumeName D:
                -DestinationComputerName FS2-Test -DestinationVolumeName R: -DestinationLogVolumeName L :
                -DurationInMinutes 1 -ResultPath c:\test -IgnorePerfTests

#--> create a storage replica partnership
New-SRPartnership -SourceComputerName FS1-Test -SourceRGName FS1RG -SourceVolumeName R: -SourceLogVolumeName L:
                  -DestinationComputerName FS2-Test -DestinationRGName FS2RG -DestinationVolumeName R: -DestinationLogVolumeName L:

#--> view replication status
(Get-SRGroup) Replicas
Get-WinEvent -ProviderName Microsoft-Windows-StorageReplica

#--> add som files to the source volume
"Hello!" > r:\file.txt
"Was it me," > r:\file2.txt
"you were looking for?" > r:\file3.txt
fsutil file createnew r:\file4.dat 1000000000

#--> reverse replication
Set-SRPartnership | -NewSourceComputerName FS2-Test -SourceRGName FS2RG -DestinationComputerName FS1-Test -DestinationRGName FS1RG

#--> remove replication and clean up
Set-SRPartnership | Remove-SRPartnership

Invoke-Command -ComputerName FS1-Test,FS2-Test -ScriptBlock {
    Get-SRGroup | Remove-SRGroup
    }