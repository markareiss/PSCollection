<#
.Synopsis
   Searches local drive for ".ps1" with the same name. After 1st occurance it "dot sources" the ps1.
.DESCRIPTION
   Searches local drive for ".ps1" with the same name. After 1st occurance it "dot sources" the ps1. Takes the default root first if run as a script and not inline.
   Does not need ".ps1" at the end 
.EXAMPLE
   . (Find-DotSource -Path $PSScriptRoot -ps1 PS1_Name_Here )
#>

Function Find-DotSource
{
    
    Param(
        # Param1 - Name of PS1
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$ps1,

        # Param2 - Path of current script. Loads default $PSScriptRoot if run as script
        [Parameter(Mandatory=$false,                   
                   Position=1)]               
        [string]$path = $PSScriptRoot,

        # Param3 - Path of current script. Loads default $PSScriptRoot if run as script
        [Parameter(Mandatory=$false,                   
                   Position=1)]               
        [string[]]$dirs = @("D:\TFS\Library\Powershell\","D:\TFS\Workspace\Powershell")
        #[string[]]$dirs = @("C:\ScriptLibrary\","D:\PowershellWorkSpace\")
        #[string[]]$dirs = ""
        )

    if(!($dirs)){
        $dirs = Get-Volume | Where {$_.DriveType -eq "Fixed" -and $_.FileSystemLabel -ne "System Reserved"} | ForEach-Object { "$($_.DriveLetter):\" }
    }
    
    if(!($ps1.Contains(".ps1"))){
        $ps1 = "$ps1.ps1"
    }

    Function Get-FirstOccurance($ps1,$dirs){
        foreach($dir in $dirs){
            $res = Get-ChildItem -Path $dir -Filter $ps1 -file -ErrorAction SilentlyContinue 
            if($res){
                $res | Select -ExpandProperty FullName
                break
            }else{
                $dirs = Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue | select -ExpandProperty FullName 

                $result = Get-FirstOccurance $ps1 $dirs
                if($result){
                    $result
                    break 
                }
            }
        }   
    }
        
    #Combine Path & PS1 for first check
    $path = "$path\$ps1"
    $exist = Test-Path $path

    if(!($exist)){  
     
        $count = 0
                     
        do{

            $path = Get-FirstOccurance -ps1 $ps1 -dirs $dirs[$count]
            $count++

        }while(!($path) -and $count -lt $dirs.Count)
    }
    
    if(!($path)){
        Write-Host "No path found for function/module" 
        Write-Host " :( :( :("       
    }else{
        $path
        Write-Host "Function/module path found"
        Write-Host "To use, the Syntax is: . (Find-DotSource -ps1 PS_Name_Here)"
    }  
}
