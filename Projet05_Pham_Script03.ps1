Import-Module ActiveDirectory
Set-ExecutionPolicy Unrestricted

$DC="sv1paris.acme.fr"
$user="#Error:XFonction#"
$listUser="#Error:XFonction#"

####################################################  
#gestion des erreurs
    Trap { 
         #continue 
    }




##################################################
#FUNCTION: Lister tous les utilisateur dans $DC :
#ATTENTION: besoin varibale $DC

function creerListUser {
    $listU=@()
    $b=Get-ADUser -Filter * -Properties * | where{$_.enabled -eq $true}
    foreach ($g in $b) { 
        $user = $g.sAMAccountName 
        $listU += $user
    }
    $listU = $listU | Sort-Object
    return $listU
}


###################################################
#FUNCTION: lister tous les utilisateur dans domaine et demander saisir un:

function saisirUtilisateurDansListe {
    $u=Read-Host -Prompt "`n`nEntrer  d'un Utilisateur"
    return $u;
}


##################################################
#FUNCTION: Lister tous les utilisateur dans $DC :
#ATTENTION: besoin varibale $DC


function tousLesGroupdUtilisateur {
    $userdn =(Get-ADUser $args[0] -Server $DC).DistinguishedName
    $liste_groupes = Get-ADUser -SearchScope Base -SearchBase $userdn -LDAPFilter '(objectClass=user)' -Properties tokenGroups -server $DC| Select-Object -ExpandProperty tokenGroups | Select-Object -ExpandProperty Value
    $liste=@()

    foreach ($g in $liste_groupes) { 
        #via port 3268, obtiendre dans ce domaine les catalogues globaux des sous-domain de Active Directory (port 389 pour le domain courant)
        $GC=$DC+":3268"
        $b= Get-ADGroup -filter { Sid -eq $g } -server $GC
      
        $r= New-Object -TypeName PSObject  -Property @{
        Groupe = $b.Name
        sDN = $b.DistinguishedName
        }         
    $liste += $r                 
    }
    return $liste
}

####################################################  
#PRINCIPAL :


#Demander saisir un utilisateur dans list:
$listinloop = @()
$listinloop = creerListUser

while ($user -notin $listinloop) {
    cls
    Write-Host "List de tous les utilisateur dans $DC`:`n"
    $listinloop
    $user=saisirUtilisateurDansListe
}


#Creer un fichier qui stock les infos cherchées :
$now=pwd 
$filenow="$now\TousLesGroupdUtilisateur.$user.txt"
New-item -path "$filenow"  -ItemType file -Force

#Write->File
$listGroupe = tousLesGroupdUtilisateur $user

Write-Host "La liste des groupes dont $user est membre:`n`n"
$listGroupe 
$listGroupe > $filenow 

#Resultat
      
echo "`n`nFichier créé dans $now"
sleep (50000)     


