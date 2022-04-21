#!/bin/bash

cd test

#--------------------------------------------------------------------------------------
# Dans un premier temps on réutilise notre script qui cree un csv avec une colonne date au bon format

tail -n+2 dataset.csv | awk -F "\"*,\"*" '{print "@"$2}' | cut -c -11 > dateColumn.csv

echo "time" > tmp1.csv
date -f dateColumn.csv +"%F" >> tmp1.csv
rm dateColumn.csv
paste -d, dataset.csv tmp1.csv > tmp2.csv

#------------------------------------------------------------------------------------
# on recupere les dates uniques et id uniques des capteurs qui ont émis des données

dates=$(tail -n+2 tmp1.csv | uniq)

rm tmp1.csv

ids=$(sort -u -t "," -k6 dataset.csv | cut -d, -f6 | head -n -1)

#-------------------------------------------------------------------------------------
#On va ici recuperer les informations souhaitees , en creant des sous fichiers de donnes par id,dates,temperature/luminosite/humidite
for id in $ids
do
#On stock les donnes de chaque capteur dans un csv a son nom
	grep $id tmp2.csv > $id.csv

#On stock la colonne des donnees de temperature dans un csv , on nettoit les donnes en enlevant les espaces et on les tries
	grep -v "^$" $id.csv | cut -d "," -f5 | grep -v "^$" | sort -nr > Temperature.csv

#On recupere les donnes souhaitees
	maxTemperatureGlobal=$(cat Temperature.csv | head -n 1)
	minTemperatureGlobal=$(cat Temperature.csv | tail -n 1)
	moyenneTemperatureGlobal=$(awk '{ total += $1; count++ } END {print total/count }' Temperature.csv)
	echo "______________________________________"
	echo "id: $id"
	echo "--- Toute la periode ---"
	echo "Temperature"
	echo "  Maximum : $maxTemperatureGlobal"
	echo "  Minimum : $minTemperatureGlobal"
	echo "  Moyenne : $moyenneTemperatureGlobal"

#On stock la colonne des donnees de luminosite dans un csv , on nettoit les donnes en enlevant les espaces et on les tries
	grep -v "^$" $id.csv | cut -d "," -f3 | grep -v "^$" | sort -nr > Luminosite.csv

#On recupere les donnes souhaitees
	maxLuminositeGlobal=$(cat Luminosite.csv | head -n 1)
	minLuminositeGlobal=$(cat Luminosite.csv | tail -n 1)
	moyenneLuminositeGlobal=$(awk '{ total += $1; count++ } END {print total/count }' Luminosite.csv)
	echo "Luminosite"
	echo "  Maximum : $maxLuminositeGlobal"
	echo "  Minimum : $minLuminositeGlobal"
	echo "  Moyenne : $moyenneLuminositeGlobal"

#On stock la colonne des donnees de humidite dans un csv , on nettoit les donnes en enlevant les espaces et on les tries
	grep -v "^$" $id.csv | cut -d "," -f4 | grep -v "^$" | sort -nr > Humidite.csv

#On recupere les donnes souhaitees
	maxHumiditeGlobal=$(cat Humidite.csv | head -n 1)
	minHumiditeGlobal=$(cat Humidite.csv | tail -n 1)
	moyenneHumiditeGlobal=$(awk '{ total += $1; count++ } END {print total/count }' Humidite.csv)

	echo "Humidite"
	echo "  Maximum : $maxHumiditeGlobal"
	echo "  Minimum : $minHumiditeGlobal"
	echo "  Moyenne : $moyenneHumiditeGlobal"

	echo "--- Par jour ---"
	


#On effectue les memes operations mais par date
	for element in $dates
	do
		grep $element $id.csv > $id$element.csv
		grep -v "^$" $id$element.csv | cut -d "," -f5 | grep -v "^$" | sort -nr > Temperature.csv
		maxTemperature=$(cat Temperature.csv | head -n 1)
		minTemperature=$(cat Temperature.csv | tail -n 1)
		moyenneTemperature=$(awk '{ total += $1; count++ } END {print total/count }' Temperature.csv)
 

		grep -v "^$" $id$element.csv | cut -d "," -f3 | grep -v "^$" | sort -nr > Humidite.csv
		maxHumidite=$(cat Humidite.csv | head -n 1)
		minHumidite=$(cat Humidite.csv | tail -n 1)
		moyenneHumidite=$(awk '{ total += $1; count++ } END {print total/count }' Humidite.csv)


		grep -v "^$" $id$element.csv | cut -d "," -f4 | grep -v "^$" | sort -nr > Luminosite.csv
		maxLuminosite=$(cat Luminosite.csv | head -n 1)
		minLuminosite=$(cat Luminosite.csv | tail -n 1) 
		moyenneLuminositeGlobal=$(awk '{ total += $1; count++ } END {print total/count }' Luminosite.csv)


		#moyenneTemperature
		
		echo "Date: $element"
		echo "Temperature"
		echo "  Maximum : $maxTemperature"
		echo "  Minimum : $minTemperature"
		echo "  Moyenne : $moyenneTemperature"

		echo "Luminosite"
		echo "  Maximum : $maxLuminosite"
		echo "  Minimum : $minLuminosite"
		echo "  Moyenne : $moyenneLuminosite"

		echo "Humidite"
		echo "  Maximum : $maxHumidite"
		echo "  Minimum : $minHumidite"
		echo "  Moyenne : $moyenneHumidite"

		echo "--------------"		

		# Si le fichier existe on le supprime
		if [ -e $id$element.csv ]
		then 
			rm $id$element.csv
		fi
	done
	
	# Si le fichier existe on le supprime   
	if [ -e $id.csv ]
	then 
		rm $id.csv
	fi

	echo "______________________________________"
done

#------------------------------------------------------------------------------------------------------------------------------------------
#Suppression des fichiers crees

if [ -e Luminosite.csv ]
then 
	rm Luminosite.csv
fi


if [ -e Temperature.csv ]
then 
	rm Temperature.csv
fi


if [ -e Humidite.csv ]
then 
	rm Humidite.csv
fi


rm tmp2.csv

# --------------------------------------------------------------------------------------
