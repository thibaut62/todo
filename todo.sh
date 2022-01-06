#!/bin/bash

##########################################################################
# Copyright: DELVILLE Thibaut
##########################################################################

##########################################################################
# Programme : petit script de tache a faire
##########################################################################

VERSION="0.2.0"; # <release>.<major change>.<minor change>
PROGRAMME="todo";
AUTHOR="DELVILLE Thibaut";

##########################################################################
# Déclaration des variables:
##########################################################################

DIALOG=${DIALOG=Xdialog}
#DIR=$(cd $( dirname ${BASH_SOURCE[0]}) && pwd ) # Récupration du chemin d'ou le sript est lancer
DATE=$(date '+%x')
PS3="Votre choix : "

##########################################################################
# Début du programme:
##########################################################################

source conf.ini
clear

##########################################################################
# On va récuperer le fichier .todo.list distant sur mon raspberry
##########################################################################

DEST_TODO=$($DIALOG --title "Emplacement du dossier ou se trouve .todo.list" --dselect / 0 0 2>&1 1>/dev/tty)
scp $PORT_SCP $ADRESSE/.todo.list $DEST_TODO/

##########################################################################
# Test si le fichier .todo.list existe sinon on le creer
##########################################################################

if [ ! -e $DEST_TODO/.todo.list ]
 then
  touch $DEST_TODO/.todo.list
 else
  sed -i '/^$/d' $DEST_TODO/.todo.list # supprimer les ligne vides
fi

###########################################################################
# Déclaration des fonctions :
###########################################################################

check-input()
{
 while [ -z "$saisi" ] 
 do
   echo "Mauvaise saisi recommencer :"
   read -p "Saisi : " saisi
 done
}

ajout() # Ajouter une tâche
{
 echo -e "\nQuel tache voulez vous ajouter ?"
 read -p "Saisi : " saisi
 check-input
 echo "$saisi ajouté le $DATE" >> $DEST_TODO/.todo.list
 scp $PORT_SCP $DEST_TODO/.todo.list $ADRESSE/
}

fait() # Marquer la ligne d'une tâche comme faite
{
 echo -e "\nQuel tâche voulez vous marquer comme faite ?"
 read -p "Saisi : " saisi
 check-input
 ligne=$(sed -n ${saisi}p $DEST_TODO/.todo.list)
 lignecomp=$(echo "$ligne FAIT")
 sed -i "${saisi}d" $DEST_TODO/.todo.list
 sed -i '/^$/d' $DEST_TODO/.todo.list
 echo $lignecomp >> $DEST_TODO/.todo.list
 scp $PORT_SCP $DEST_TODO/.todo.list $ADRESSE/
}

supp() # Supprimer une ligne de tâche
{
 echo -e "\nQuel tâche voulez vous marquer comme finie ?"
 read -p "Saisi : " saisi
 check-input
 sed -i "${saisi}d" $DEST_TODO/.todo.list
 scp $PORT_SCP $DEST_TODO/.todo.list $ADRESSE/
}

list-a-faire() # Afficher la liste à faire
{
 clear
 echo -e "\e[92m-----------------------------"
 echo -e "| Liste des tâches a faires :"
 echo -e "-----------------------------\n\e[0m"
 nl $DEST_TODO/.todo.list | grep -v FAIT
 echo -e "\n----------\n"
}

list-fait() # Afficher la liste des tâches marquées comme lu
{
 clear
 echo -e "\e[92m---------------------------"
 echo -e "| Liste des tâches faites :"
 echo -e "---------------------------\n\e[0m"
 nl $DEST_TODO/.todo.list | grep FAIT
 echo -e "\n----------\n"
}

menu() # Menu
{
 select item in "Ajouter une tâche" "Marquer une tâche FAITE" "Afficher les tâches faites" "Supprimer une tâche" "Retour" "Quitter"
  do
    case $REPLY in
                  1)
                    ajout
                    list-a-faire
                    menu
                    ;;
                  2)
                    fait
                    list-a-faire
                    menu
                    ;;
                  3)
                    list-fait
                    menu
                    ;;
                  4)
                    supp
                    list-a-faire
                    menu
                    ;;
                  5)
                    list-a-faire
                    menu
                    ;;
                  6)
                    clear
                    scp $PORT_SCP $DEST_TODO/.todo.list $ADRESSE/
                    rm $DEST_TODO/.todo.list                    
                    echo "Bonne fin de journée."
                    exit
                    ;;
                  *)
                    echo -e "\e[91mChoix incorrect\e[0m"
                    ;;
              esac
 done
}

list-a-faire
menu
