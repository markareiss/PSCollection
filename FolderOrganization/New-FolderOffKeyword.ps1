function New-FolderOffKeyword ($path, $keyword, $NoName = $false)
{
    if(Test-Path $path){
        
        $files = Get-ChildItem -Path $path -Filter *$keyword* -File

        if($files){
            if($NoName){
                $keyword = "NoName"
            }

            $FinalPath = "$path/$keyword"

            if(!(Test-Path "$FinalPath")){

                New-Item -ItemType Directory -Name $keyword -Path $path
            }

            foreach ($f in $files)
            {
                Move-Item -Path $f.fullname -Destination $FinalPath    
            }
        
        }else{
            Write-Warning "No files with $keyword"        
        }
    }else{
        Write-Warning "$path does not exist"
    }

    
}
