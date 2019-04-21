Import-Module ActiveDirectory
Set-ExecutionPolicy Unrestricted

$DC="sv1paris.acme.fr"
$baseSearch = "OU=Immeuble RP,DC=acme,DC=fr"
cls

##################################################
#gestion des erreurs
    Trap { 
         #continue 
    }


##################################################
#FUNCTION: Lister tous les groupe dans $DC :
#ATTENTION : besoin varibale $baseSearch et $DC

function listTousLesGroupesDansDomaine{
    Get-ADGroup -Filter * -SearchBase $baseSearch 
}



##################################################
#FUNCTION: Creer liste :
#ATTENTION: besoin varibale $nomGroup et fonction listTousLesGroupesdUtilisateur 


function makeList{
    $liste_groupes = Get-ADGroupMember -Identity $args[0] -Recursive 
    $liste_groupes = $liste_groupes.name | Sort-Object
    return $liste_groupes
}
##################################################
#Principal:

$list = listTousLesGroupesDansDomaine
$list = $list.name | Sort-Object
$nomGroup="##error:Function##"

while ($nomGroup -notin $list) {
    cls
    $list
    $nomGroup=Read-Host -Prompt "`n`nEntrer Nom d'un groupe"
}


$a= makeList $nomGroup

echo "`n`nCe sont les utilisateurs dans groupe : $nomGroup`n`n"
$a

#Creer un fichier qui stock les infos cherchées :

$now=pwd 
$filenow="$now\ListerLesMembreDuGroupe.$nomGroup.txt"
New-item -path "$filenow"  -ItemType file -Force

#Write->File
$a > $filenow 

#Resultat
      
echo "`n`nFichier créé dans $now"
sleep (50000)