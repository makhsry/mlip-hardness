#!/bin/bash
echo ++++++++++++++++++++++++++++++++++++++++
echo file -MAIN.sh- is open ....
echo on server $(hostname)
echo current directory = $(pwd)
echo ++++++++++++++++++++++++++++++++++++++++
echo setting training flag 
cycleF=1 # flag for training -1= needed-0=not needed
echo training flag is set as $cycleF --  1= needed-0=not needed
echo ++++++++++++++++++++++++++++++++++++++++
echo reading USER settings from directory -usr- 
echo reading default values and exporting to directory tmp
echo reading total number of lammps dynamic runs -m-
m=$(cat ../usr/"M")
cp ../usr/"M" ../tmp/
echo m is $m 
echo reading file TERMINATION for soft terminating - cycles cannot exceed it 
termination=$(cat ../usr/"TERMINATION")
echo runs will stop if the cycle exceeds -$termination- 
echo to increase or decrease this value modify file TERMINATION in default directory
echo detecting debug mode status 
debug=$(cat ../usr/"DEBUG")
echo debug mode = $debug -on=1-off=0-
echo detecting task mode 
mode=$(cat ../usr/"MODE")
echo mode is $mode -0=genMTP-1=ExtSys-2=Neigh-
echo reading file MAINPATH 
mainpath=$(cat ../usr/"MAINPATH")
echo main directory path is $mainpath  
echo ++++++++++++++++++++++++++++++++++++++++
echo reading file SCRATCHPATH 
scratchpath=$(cat ../usr/"SCRATCHPATH")
echo main directory path is $scratchpath  
echo ++++++++++++++++++++++++++++++++++++++++
echo reading file TERMINATED 
cont=$(cat ../usr/"TERMINATED")
echo a previosuly terminated run state = $cont 
echo ++++++++++++++++++++++++++++++++++++++++
echo determining the dropped cycle
if [ "$cont" -eq "1" ]; then 
	cycle=$(cat ../tmp/"CYCLE")
	echo previously dropped cycle = cycle $cycle
else
	echo no previously dropped cycle is set 
	cycle=0 # training cycles counter 
	echo "$cycle" > ../tmp/CYCLE
	echo creating directory: ../runs in parent directory 
	mkdir ../runs
	echo created directory: ../runs 
fi
echo ++++++++++++++++++++++++++++++++++++++++
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
###############################################################
if [ "$debug" -eq "1" ]; then
echo debug mode is ON - user interactions is requested 
echo enetring main-global loop 
echo - - SLEEPs 30s 
sleep 30s 
while [ "$cycleF" -eq "1" ]
do
	echo file is open on server $(hostname)
	echo the cycle flag is set as $cycleF
	echo ++++++++++++++++++++++++++++++++++++++++
	echo determining cycle 
	cycle=$(cat ../tmp/"CYCLE")
	echo cycle=$cycle
	echo ++++++++++++++++++++++++++++++++++++++++
	echo checking the cycles soft termination state 
	if [ "$cycle" -gt "$termination" ]; then
		echo cycle exceeds $termination - terminating ...
		break
	fi
	echo cycles soft termination is NOT exceeded yet 
	echo ++++++++++++++++++++++++++++++++++++++++
	echo creating cycle directories under -runs- directory 
	echo on server $(hostname)
	echo - - SLEEPs 30s 
	sleep 30s 
	echo creating directory: ../runs/$cycle/
	mkdir ../runs/"$cycle"/
	echo creating directory:../runs/$cycle/vaspEF/
	mkdir ../runs/"$cycle"/vaspEF/
	echo creating directory: ../runs/$cycle/mlip/
	mkdir ../runs/"$cycle"/mlip/
	echo creating directory: ../runs/$cycle/mlip/POSCAR/
	mkdir ../runs/"$cycle"/mlip/POSCAR/
	echo ++++++++++++++++++++++++++++++++++++++++
	# assuming always drops start with lammps re-activation .... 
	if [ "$cont" -eq "0" ]; then
		echo ++++++++++++++++++++++++++++++++++++++++
		if [ "$cycle" -eq "0" ]; then
			echo cycle is $cycle 
			echo ++++++++++++++++++++++++++++++++++++++++
			if [ "$mode" -eq "2" ]; then
				echo detected mode = updating MTP for extended system based on LEARNING by NEIGHBORHOOD with OTFAL
				echo - - SLEEPs 30s 
				sleep 30s 
				echo copying -curr.mtp- from tmp/ to runs/$cycle/mlip/
				echo initial LAMMPS runs do not need -state.mvs- file 
				echo see .ini files for more info 
				echo all the extrapolated configurations will be used as trainset after selection using -curr.mtp- file
				cp ../tmp/curr.mtp ../runs/"$cycle"/mlip/
				echo file -curr.mtp- copied  
			fi
			echo ++++++++++++++++++++++++++++++++++++++++
		else 
			echo cycle is $cycle 
			echo ++++++++++++++++++++++++++++++++++++++++
			echo preparing to detect extrapolated CFGs from previous run and sample them 
			echo - - SLEEPs 30s 
			sleep 30s 
			./sampling.sh
			echo entering directory ../runs/$cycle/mlip/
			cd ../runs/"$cycle"/mlip/ 		
			while [ ! -f "sampled.cfg" ]
				do
					sleep 30s
			done
			echo executed sampling of extrapoltaed configurations
			echo sampling is completed 
			echo ++++++++++++++++++++++++++++++++++++++++
			echo cleaning .... 
			dummy=$(($cycle-1))
			#echo a dummy -new_state.mvs- is generated - renaming it to -new_state_dummy.mvs- 
			#mv new_state.mvs new_state_dummy.mvs
			#echo renamed -new_state.mvs- file to -new_state_dummy.mvs- 
			echo creating a backup of sampled.cfg as sampled_old.cfg 
			cp sampled.cfg sampled_old.cfg
			echo created a backup of sampled.cfg as sampled_old.cfg
			echo creating new trainset from sampled.cfg 
			mv sampled.cfg trainset.cfg
			echo renamed sampled.cfg to trainset.cfg
			echo new trainset is generated as trainset.cfg
			echo leaving directory ../runs/$cycle/mlip/
			cd ../../../sh/ 
			echo current directory = $(pwd)
			echo ++++++++++++++++++++++++++++++++++++++++
			echo start generating POSCAR files from trainset.cfg
			echo - - SLEEPs 30s 
			sleep 30s 
			./cfg2poscar.sh
			echo ++++++++++++++++++++++++++++++++++++++++
			echo deleting -trainset.cfg- file without E and F - 
			echo which is the sampled from extrapolated cfgs -../runs/$cycle/mlip/trainset.cfg- 
			rm ../runs/"$cycle"/mlip/trainset.cfg 
			echo deleted trainset.cfg file without E and F -../runs/$cycle/mlip/trainset.cfg-		
			echo ++++++++++++++++++++++++++++++++++++++++
			echo start counting POSCAR files located in ../runs/$cycle/mlip/POSCAR/
			echo - - SLEEPs 30s 
			sleep 30s 
			./cout.sh
			echo ++++++++++++++++++++++++++++++++++++++++
			echo preparing to launch vaspEF runs
			echo - - SLEEPs 30s 
			sleep 30s 
			n=$(cat ../tmp/"N")
			echo number of vaspEF runs is set to n=$n 
			echo preparing directories and files for vaspEF runs ...  
			echo - - SLEEPs 30s 
			sleep 30s 
			for i in `seq 1 $n`;
					do
				if [ "$n" -gt "1" ]; then
					echo more than 1 extrapolated configuration is detected - opening vaspEFmulti.sh file 
					echo "$i" > ../tmp/I
					./vaspEFmulti.sh
					
				else
					echo only 1 extrapolated configuration is detected - opening vaspEFsingle.sh file
					echo "$i" > ../tmp/I
					./vaspEFsingle.sh
				fi 
			done
			echo prepared directories and files for vaspEF runs ...
			echo ++++++++++++++++++++++++++++++++++++++++ 
			echo copying vaspEF directory from ../runs/$cycle/vaspEF/ on $(hostname) to 10.30.16.62 server
			echo starting copy process ... 
			scp -i ~/.ssh/id_rsa -r ../runs/$cycle/vaspEF mkhansary@10.30.16.62:/home/mkhansary/ 	
			echo finished copy 
			echo VASP files on 10.30.16.62 server are ready for vaspEF runs ...
			echo ++++++++++++++++++++++++++++++++++++++++
			echo copying total number of vasp runs -N- to 10.30.16.62 
			scp -i ~/.ssh/id_rsa ../tmp/N mkhansary@10.30.16.62:/home/mkhansary/ 
			echo copied total number of vasp runs -N- to 10.30.16.62
			echo ++++++++++++++++++++++++++++++++++++++++
			echo copying cycle number to 10.30.16.62 
			scp -i ~/.ssh/id_rsa ../tmp/CYCLE mkhansary@10.30.16.62:/home/mkhansary/ 
			echo copied cycle number to 10.30.16.62
			echo ++++++++++++++++++++++++++++++++++++++++
			echo copying -on62.sh- to 10.30.16.62 
			scp -i ~/.ssh/id_rsa on62.sh mkhansary@10.30.16.62:/home/mkhansary/ 
			echo copied -on62.sh- to 10.30.16.62
			echo ++++++++++++++++++++++++++++++++++++++++
			echo executing calculations on 62 by using -on62.sh-  
			ssh -i ~/.ssh/id_rsa mkhansary@10.30.16.62 ~/on62.sh
			echo executed -on62.sh- on 62
			echo ++++++++++++++++++++++++++++++++++++++++
			echo moving ../runs/$cycle/vaspEF to ../runs/$cycle/vaspEF_Pre
			mv ../runs/$cycle/vaspEF ../runs/$cycle/vaspEF_Pre
			echo moved ../runs/$cycle/vaspEF to ../runs/$cycle/vaspEF_Pre
			echo ++++++++++++++++++++++++++++++++++++++++
			echo waiting for vaspEF runs on 62 to be finished and file transfer
			echo monitoring presence of -vaspEF- directory at ~/vaspEF/
			while [ ! -d ~/vaspEF ]
				do
					sleep 30s
			done
			echo directory -vaspEF- is detected
			echo moving directory -vaspEF- from home to ../runs/$cycle/vaspEF/
			mv ~/vaspEF ../runs/$cycle/vaspEF
			echo moved directory -vaspEF- from home to ../runs/$cycle/vaspEF/
			echo file transfer from 62 to 61 is confirmed 
			echo ++++++++++++++++++++++++++++++++++++++++
			echo monitoring vaspEF runs progress for completion  
			echo - - SLEEPs 30s 
			sleep 30s
			for i in `seq 1 $n`;
				do
				echo enterning directory ../runs/$cycle/vaspEF/$i/ and looking for file OUTCAR_copy
				cd ../runs/"$cycle"/vaspEF/"$i"/
				echo current directory changed to = $(pwd)
				while [ ! -f "OUTCAR_copy" ]
					do
						sleep 30s
				done
				echo  file OUTCAR_copy detected in ../runs/$cycle/vaspEF/$i/
				echo vaspEF$i completed
				echo leaving directory ../runs/$cycle/vaspEF/$i/
				cd ../../../../sh/
				echo current directory changed to = $(pwd)
			done
			echo all vaspEF runs finished
			echo ++++++++++++++++++++++++++++++++++++++++
			echo converting vasp OUTCARs to one appended-CFG file
			echo - - SLEEPs 30s 
			sleep 30s 
			./outcar2cfg.sh 	
			echo ++++++++++++++++++++++++++++++++++++++++
			############################################################
			echo checking the special case i.e. mode=2-cycle=1 where no pre-existing -state.mvs- and -trainset.cfg- exist in ../../"$dummy"/mlip/
			echo - - SLEEPs 30s 
			sleep 30s 
			skip=0
			echo skip is set as $skip - default - performing files backup
			if [ "$mode" -eq "2" ]; then
				if [ "$cycle" -eq "1" ]; then
					echo mode is $mode and cycle is $cycle - 
					echo for this special case no pre-existing -state.mvs- and -trainset.cfg- exist in ../../"$dummy"/mlip/
					skip=1
					echo skip set as $skip - skipping files backup
				fi 
			fi 
			############################################################
			echo special case is checked and skip is set as $skip - continueing to trainset preparation ....
			echo - - SLEEPs 30s 
			sleep 30s 
			if [ "$skip" -eq "0" ]; then
				echo skip set as $skip - performing file backup
				echo - - SLEEPs 30s 
				sleep 30s 
				echo for data backup --- downloading -state.mvs- file from round $dummy to round $cycle mlip subdirectory 
				cp ../runs/"$dummy"/mlip/state.mvs ../runs/"$cycle"/mlip/state.mvs
				echo copied file state.mvs from ../runs/$dummy/mlip/ to ../runs/$cycle/mlip/
				echo making a copy of ../runs/$dummy/mlip/trainset.cfg as ../runs/$cycle/mlip/trainsetP.cfg
				cp ../runs/"$dummy"/mlip/trainset.cfg ../runs/"$cycle"/mlip/trainsetP.cfg
				echo copied ../runs/$dummy/mlip/trainset.cfg as ../runs/$cycle/mlip/trainsetP.cfg
				echo copying ../runs/$cycle/mlip/trainsetP.cfg ../runs/$cycle/mlip/trainset.cfg
				cp ../runs/"$cycle"/mlip/trainsetP.cfg ../runs/"$cycle"/mlip/trainset.cfg
				echo copied ../runs/$cycle/mlip/trainsetP.cfg ../runs/$cycle/mlip/trainset.cfg
				echo adding -trainsetN.cfg- to the end of -trainset.cfg- 
				cat ../runs/"$cycle"/mlip/trainsetN.cfg >> ../runs/"$cycle"/mlip/trainset.cfg
				echo added cfgs from trainsetN.cfg to the end of trainset.cfg 
				echo trainset.cfg file is ready for curr.mtp training
			else
				echo skip set as $skip  
				echo detected special case ---- mode is $mode and cycle is $cycle - 
				echo for this special case no pre-existing -state.mvs- and -trainset.cfg- exist in ../../"$dummy"/mlip/
				echo - - SLEEPs 30s 
				sleep 30s 
				echo for data backup --- downloading -state.mvs- file from round $dummy to round $cycle mlip subdirectory 
				cp ../runs/"$dummy"/mlip/state.mvs ../runs/"$cycle"/mlip/state.mvs
				echo copied file state.mvs from ../runs/$dummy/mlip/ to ../runs/$cycle/mlip/
				echo adding -trainsetN.cfg- to the end of -trainset.cfg- --- in this case -trainset.cfg- is empty at first 
				cat ../runs/"$cycle"/mlip/trainsetN.cfg >> ../runs/"$cycle"/mlip/trainset.cfg
				echo added cfgs from trainsetN.cfg to the end of trainset.cfg 
				echo trainset.cfg file is ready for curr.mtp training
			fi
			echo ++++++++++++++++++++++++++++++++++++++++
			echo entering training process ...
			echo - - SLEEPs 30s 
			sleep 30s 
			./training.sh 
			echo ++++++++++++++++++++++++++++++++++++++++
			echo start monitoring training progress
			echo entering ../runs/$cycle/mlip
			cd ../runs/"$cycle"/mlip
			echo current directory = $(pwd)
				while [ ! -f "curr.mtp_copy" ]
					do
						sleep 30s
				done
			echo file -curr.mtp_copy- detected 
			echo leaving ../runs/$cycle/mlip
			cd ../../../sh/
			echo current directory = $(pwd)
			echo training task completed
			echo ++++++++++++++++++++++++++++++++++++++++
			echo generating MVS file 
			echo - - SLEEPs 30s 
			sleep 30s 
			./genMVS.sh
		fi 
		echo ++++++++++++++++++++++++++++++++++++++++
	fi
	cont=0
	echo ++++++++++++++++++++++++++++++++++++++++
	echo initializing lammps MD runs
	echo on server $(hostname)
	echo - - SLEEPs 30s 
	sleep 30s 
	echo number of lammps MD runs is m = $m
	echo $m different seeds will be fed to velocity command in lammps input file 
	echo preparing lammps MD run directories
	echo creating directory: ../runs/$cycle/lmpRX/
	mkdir ../runs/"$cycle"/lmpRX/
	echo directory created: ../runs/$cycle/lmpRX/
	echo ++++++++++++++++++++++++++++++++++++++++
    echo preparing to launch lmpRX runs
	echo - - SLEEPs 30s 
	sleep 30s 
	./lmpS2.sh
	echo ++++++++++++++++++++++++++++++++++++++++
    echo all lmpRX instances are launched
	echo ++++++++++++++++++++++++++++++++++++++++
	echo checking whether last instace -$m- is launched or not to start monitoring 
	while [ ! -d ../runs/$cycle/lmpRX/$m/ ]
		do
            sleep 30s
	done 
	echo final instance -$m- has been launched  
	echo ++++++++++++++++++++++++++++++++++++++++	
    echo checking lammps run progress and termination ...
    for j in `seq 1 $m`;
    do
        echo checking whether lmpRXrun=$j is completed or not
        echo entering directory ../runs/$cycle/lmpRX/$j/
        cd ../runs/"$cycle"/lmpRX/"$j"/
		echo current directory = $(pwd)
        echo monitoring presence of file -lmpRXfinished-
        while [ ! -f "lmpRXfinished" ]
            do
                sleep 30s
        done
		echo file -lmpRXfinished- detected in directory ../runs/$cycle/lmpRX/$j/
        echo leaving directory ../runs/$cycle/lmpRX/$j/
        cd ../../../../sh/
		echo current directory = $(pwd)
    done
	echo ++++++++++++++++++++++++++++++++++++++++
	echo all lammps instances are checked for termination
	echo ++++++++++++++++++++++++++++++++++++++++
    echo checking failure/success of each lmpRXrun instance
	echo - - SLEEPs 30s 
	sleep 30s 
	./checkfail.sh
	echo ++++++++++++++++++++++++++++++++++++++++
    echo deciding whether another training round is needed or not
    echo decision critria = value of sumfails
	echo if value of sumfails is greater than 0 then training is needed
	sumfails=$(cat ../tmp/"SUM")
    echo value of sumfails = $sumfails
    if [ "$sumfails" -gt "0" ]; then
        echo another training is needed
		echo updating training cyle flag -cycleF- 
        cycleF=1
		echo cycle flag is updated -cycleF-=$cycleF
		echo updating cycle counter -cycle- 
		cycle=$(($cycle+1))
		echo cycle counter is updated -cycle-=$cycle 
    else
		echo no further training is needed. 
		echo updating training cyle flag -cycleF-
    	cycleF=0
		echo cycle flag is updated -cycleF-=$cycleF
    fi
	echo exporting cycle value to file -CYCLE- in ../tmp/ directory
	echo "$cycle" > ../tmp/CYCLE
	echo exported cycle value to file -CYCLE- in ../tmp/ directory
	echo - - SLEEPs 30s 
	sleep 30s 
	echo ++++++++++++++++++++++++++++++++++++++++
	echo moving all data from home directory to scratch directory - deactivated 
	echo - - SLEEPs 30s 
	sleep 30s
	cp -avr /$mainpath/runs/$cycle ../../$scratchpath/
	dummy1=$(($cycle-2))
	rm -r /$mainpath/runs/$dummy1 
done 
fi
# End of file 
