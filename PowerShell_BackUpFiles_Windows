
Import-Module ActiveDirectory
Set-ExecutionPolicy Unrestricted
cls


##################################################
#Lister tous les utilisateur dans $DC :

function creerListUser {
    $listU=@()
    $b=Get-ADUser -Filter * -Properties * | where{$_.enabled -eq $true}
    foreach ($g in $b) { 
        $user = $g 
        $listU += $user
    }
    $listU = $listU.SamAccountName | Sort-Object
    return $listU
}


 

##################################################
#gestion des erreurs
    Trap { 
         #continue 
    }

###################################################
#FUNCTION: Creer liste de tous les post dans réseaux

function makeList{
    $list_pcf = Get-ADComputer -Filter * | Where-Object {$_.Name -like "DESTOP*"} 
    $list_pcf = $list_pcf.name | Sort-Object
    return $list_pcf
}



###################################################
#FUNCTION: Creer path de chaque post et mettre dans un list
#ATTENTION: Cette fonction a besoin les fonctions: makeList et creerListUser
#

function backupPCs{
    $listPath=@()
    
    $listPC= makeList
    echo "Liste de tous les PC dans réseau:`n"
    $listPC

    $listUser= creerListUser
    echo "`n`nListe de tous les utilisateurs du base `"$baseSearch`":`n"
    $listUser
    

    $date = Get-Date -Format d.MMMM.yyyy
    $destinationUserFolder = "\\sv1paris\sav$\backUpPCs.$date"
    
    
    $pathIsHere = test-Path $destinationUserFolder
    if ($pathIsHere -eq $true) {
        write-Host "`n`nDossier existe déjà"
    }
    else{
        mkdir $destinationUserFolder
        write-Host "`n`n$destinationUserFolder créé"
    } 
    foreach ($pc in $listPC){
        write-Host "`n`n$pc>>>`n"
        $destinationPCfolder = "\\sv1paris\sav$\backUpPCs.$date\$pc"
        $path1 = test-Path $destinationPCfolder
        # Backup Server Process started
        if ($path1 -eq $true) {
            write-Host "Dossier pour sauvegarder $pc existe déjà"
        } 
        elseif ($path1 -eq $false) {
            write-Host "Dossier pour sauvegarder $pc non existe, dossier $pc creer>>>"
            mkdir $destinationPCfolder
        }


        $listFolderUseronThisPC= Get-ChildItem \\$pc\C$\Users -Directory | ForEach-Object name
        foreach ($folderUser in $listFolderUseronThisPC) {
            foreach ($nameuser in $listUser){
                    if ("$folderUser" -match "$nameuser"){
                        $pathtest = "\\$pc\C$\Users\$folderUser"
                        write-Host "Vérifier $nameuser correspondre à $pathtest"
                        
                        $pathIsGood = test-Path $pathtest
                        if ($pathIsGood -eq $true){
                            #System Variable for backup pc
                            write-Host "$pathtest est correct.  Sauvegarde $folderUser COMMENCE >>>>>>"
                            $destination = "$destinationPCfolder\$folderUser"
                            $source = $pathtest
                            $path = test-Path $destination
                            # Backup Server Process started
                            if ($path -eq $true) {
                                write-Host "Dossier existe déjà"
                            } 
                            elseif ($path -eq $false) {
                                mkdir $destination
                                write-Host "`n`n$destination créé"
                                robocopy $source $destination /XJ /E /R:1 /W:1 /SEC /SECFIX /LOG+:"$destination\backupPCs_log.txt"
                                #$backup_log = Dir -Recurse $destination | out-File "$destination\backupPCs_log.txt"
                                #$attachment = "$destination\backupPCs_log.txt"
                            }
                        }
                    }
                }           
            }
        }
    write-host "Sauvegarde réussie"
    }


###################################################
#Principal
cls
backupPCs $listPCs
 



