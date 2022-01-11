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
DIR=$($DIALOG --title "Emplacement du dossier ou se trouve .todoL.list" --dselect / 0 0 2>&1 1>/dev/tty)
DATE=$(date '+%x')
PS3="Votre choix : "

##########################################################################
# Début du programme:
##########################################################################

clear

##########################################################################
# Test si le fichier .todoL.list existe sinon on le creer
##########################################################################

if [ ! -e $DIR/.todoL.list ]
 then
  touch $DIR/.todoL.list
 else
  sed -i '/^$/d' $DIR/.todoL.list # suppr ligne vides
fi

###########################################################################
# Déclaration des fonctions :
###########################################################################

function check-input()
{
 while [ -z "$saisi" ] 
 do
   echo "Mauvaise saisi recommencer :"
   read -p "Saisi : " saisi
 done
}

function ajout()
{
 echo -e "\nQuel tache voulez vous ajouter ?"
 read -p "Saisi : " saisi
 check-input
 echo "$saisi ajouté le $DATE" >> $DIR/.todoL.list
}

function fait()
{
 echo -e "\nQuel tâche voulez vous marquer comme faite ?"
 read -p "Saisi : " saisi
 check-input
 ligne=$(sed -n ${saisi}p $DIR/.todoL.list)
 lignecomp=$(echo "$ligne FAIT")
 sed -i "${saisi}d" $DIR/.todoL.list
 sed -i '/^$/d' $DIR/.todoL.list
 echo $lignecomp >> $DIR/.todoL.list
}

function supp()
{
 echo -e "\nQuel tâche voulez vous marquer comme finie ?"
 read -p "Saisi : " saisi
 check-input
 sed -i "${saisi}d" $DIR/.todoL.list
}

function list-a-faire()
{
 clear
 echo -e "\e[92m-----------------------------"
 echo -e "| Liste des tâches a faires :"
 echo -e "-----------------------------\n\e[0m"
 nl $DIR/.todoL.list | grep -v FAIT
 echo -e "\n----------\n"
}

function list-fait()
{
 clear
 echo -e "\e[92m---------------------------"
 echo -e "| Liste des tâches faites :"
 echo -e "---------------------------\n\e[0m"
 nl $DIR/.todoL.list | grep FAIT
 echo -e "\n----------\n"
}
function menu()
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