#!/bin/bash

#color_management
 txtblk='\e[0;30m' # Black - Regular
 txtred='\e[0;31m' # Red
 txtgrn='\e[0;32m' # Green
 txtylw='\e[0;33m' # Yellow
 txtblu='\e[0;34m' # Blue
 txtpur='\e[0;35m' # Purple
 txtcyn='\e[0;36m' # Cyan
 txtwht='\e[0;37m' # White
#########################3

###############################|
paplay bgm.mp3 &
music_pid=`echo "$!"`
###############################|

#var_management
from_dir="$1"
to_dir="$2"
shift
shift
del_flag=0
transfers_done=0
folders_made=0
s_chosen="ext"
exclusions=""
log_name="log.txt"
ignore_hidden=0
#########################|

#encorporating the options
############################|
while getopts 'ds:e:l:i' OPTION ;
 do
     case "$OPTION" in
         d) del_flag=1 ;;
         s) s_chosen=$OPTARG;;
         e) exclusions=$OPTARG;;
         l) log_name=$OPTARG;;
         i);;
         ?)echo -e "Usage : bash script.sh <source_dir> <destination_dir> -s <date/ext> -e <extensions_to_be_excluded FS=,> <-d> -l <log_name>"
           exit 1;;
     esac
 done
 #########################|
#handle no optargs passed error !

#remove pre-existing logfile of the same name
if [ -f $log_name ]
then
    rm -f $log_name
fi

#################################################################################|
echo -e "${txtgrn}FileName      SourceDir       DestinationDir      TimeStamp${txtwht}" >> $log_name

#welcome Label
echo -e  "${txtylw}-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^"
echo -e "|                    Heyyy! Welcome TO t0rvalds                      |"
echo -e "-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^${txtwht}"
#############################################################################|

#running zip preprocessor_ to construct recursive zip tree
#############################################################################|

 while  [ `find $from_dir -name "*.zip" -type f | wc -l` -gt 1 ] ;
 do
     for i in `find $from_dir -name "*.zip" -type f`;
     do
         name=`echo $i | awk 'BEGIN{FS="/"} {print $NF}'`
         path=`echo $i | sed -n -e "s/$name$//p"`
         unzip -o -q $i -d $path/$name'(unpack)' 2> /dev/null
         mv $i $i"^"
     done
 done

 for i in `find $from_dir -name "*.zip^" -type f` ;
 do
    mv $i  `echo $i | sed 's/\^//g'`
 done
#####################################################|

#exclusions
 if [ ! $exclusions = ""  ]
 then
     echo -e "t0rvalds : exclusions are on, excluding files with extensions "
     echo $exclusions | sed 's/,/ /g' > .exclusions_list
     for exc in `cat .exclusions_list 2>/dev/null`
     do
         echo -e "${txtred}$exc${txtwht}"
     done
 fi
 #handle ""
#####################################################|

 #main_program
 #to organize by extensions
  if [ $s_chosen = "ext" ]
  then
      echo -e "t0rvalds : organizing by extension"
  for i in `find $from_dir -type f | sed -n '/\.[^/]\+$/p'  ` ;
  do
      count=`echo $i | grep -c "(unpack)"` #to check if lookig in an archive
      exclude_flag=0
      name=`echo $i | awk 'BEGIN{FS="/"} {print $NF}'` #name with extension
      ext=`echo $name | awk 'BEGIN{FS="."} {print $NF}'`
      path=`echo $i | sed -n -e "s/$name$//p"`
      if [ $count -ge 1 ]
      then
          echo -e "t0rvalds : looking in archive ${txtcyn}$path${txtwht}"
      fi
      #create the destination folder if doesn't exists
      if [ ! -d $to_dir ]
      then
          echo -e "${txtpur}t0rvalds : the destination folder doesn't exists, making one...${txtwht}"
          mkdir -p $to_dir
      fi
      #handling exclusions
      for exc in `cat .exclusions_list 2> /dev/null`
      do
          if [ $exc = $ext ]
          then
              echo -e "t0rvalds : exclusion raised for $name as ${txtred}.$exc ${txtwht}files are excluded..."
              exclude_flag=1
          fi
      done

  if [ ! $exclude_flag = 1 ]
  then
      if [ -d $to_dir/ext_$ext ] ;
      then
          if [ -f $to_dir/ext_$ext/$name ] #check if a file with same name already exists at the destination directory
          then
              name_orig=`echo $name | sed 's/\.[^.].*$//'`
              #name_orig=$name
              name=$name_orig
              j=0
              while [ -f $to_dir/ext_$ext/$name"."$ext ] #iteratively check if the file_N exists
              do
                  echo -e "t0rvalds : $name"."$ext exists in destination folder"
                  let "j=j+1"
                  name=$name_orig"_"$j
              done
              cp -p $i /tmp
              mv /tmp/$name_orig"."$ext /tmp/$name"."$ext
              mv /tmp/$name"."$ext $to_dir/ext_$ext
              name=$name"."$ext
              echo -e "t0rvalds : copying $name_orig.$ext as $name"
          else

          echo -e "t0rvalds : copying $name to folder ext_$ext"
          cp -p $i $to_dir/ext_$ext
          fi
          let "transfers_made=transfers_made+1"
          echo $i >> .files_moved
          echo -e "${txtylw}$name${txtwht}       $i        $to_dir/ext_$ext/${txtylw}$name${txtwht}     ${txtpur}`date '+%T '`${txtwht}">> $log_name
          echo -e "${txtylw}$name${txtwht}       $i        $to_dir/ext_$ext/${txtylw}$name${txtwht}     ${txtpur}`date '+%T '`${txtwht}">> $log_name
      else
          echo -e "t0rvalds : making directory ext_$ext"
          mkdir $to_dir/ext_$ext
          let "folders_made=folders_made+1"
          echo -e "t0rvalds : copying $name to folder ext_$ext"
          cp -p $i $to_dir/ext_$ext
          let "transfers_made=transfers_made+1"
          echo $i >> .files_moved
          echo -e "${txtylw}$name${txtwht}       $i        $to_dir/ext_$ext/${txtylw}$name${txtwht}     ${txtpur}`date '+%T '`${txtwht}">> $log_name
          echo -e "${txtylw}$name${txtwht}       $i        $to_dir/ext_$ext/${txtylw}$name${txtwht}     ${txtpur}`date '+%T '`${txtwht}">> $log_name
      fi
      echo $to_dir/ext_$ext >> .folder_list
  fi
  done
  fi
  #######################################################################################################################|

  #############################################################################|
   #main_program_date
   if [ $s_chosen = "date" ]
   then
       echo -e "t0rvalds : organizing by date created"
   for i in `find $from_dir -type f` ;
   do
       #echo $i
       count=`echo $i | grep -c "(unpack)"` #check if looking in an archive
       exclude_flag=0 #flags 0 if the particular extension is to be excluded
       name=`echo $i | awk 'BEGIN{FS="/"} {print $NF}'`
       ext=`echo $name | awk 'BEGIN{FS="."} {print $NF}'`

       if [ $ext == $name ] #handler for empty extensions
       then
       ext=""
       fi

       path=`echo $i | sed -n -e "s/$name$//p"`
       if [ $count -ge 1 ]
       then
           echo -e "t0rvalds : looking in archive $path"
       fi
       if [ ! -d $to_dir ] #create destination directory if doesn't exists
       then
           echo -e "t0rvalds : the destination folder doesn't exists, creating"
           mkdir -p $to_dir
       fi
       ddmmyyyy=`stat $i | sed -n '/Birth/p' | awk 'BEGIN{FS=" "}{print $2}' | awk 'BEGIN{FS="-"} {print $3$2$1}'`

       for exc in `cat .exclusions_list 2> /dev/null`
       do
           if [ $exc == $ext ]
           then
               echo -e "t0rvalds : exclusion raised for $name as .$exc files are excluded..."
               exclude_flag=1
           fi 2>/dev/null
       done
   if [ ! $exclude_flag = 1 ]
   then
      if [ -d $to_dir/$ddmmyyyy ] ;
       then
           if [ -f $to_dir/$ddmmyyyy/$name ]  #if file with the name already exists
           then

#              mv $to_dir/$ddmmyyyy/$name $to_dir/$ddmmyyyy/dummy
#              cp -p $i $to_dir/$ddmmyyyy
#             new_name=`echo $name | sed 's/\.[^.].*$//'`
#              mv $to_dir/$ddmmyyyy/$name $to_dir/$ddmmyyyy/$new_name"_"$ddmmyyyy"."$ext
#              mv $to_dir/$ddmmyyyy/dummy $to_dir/$ddmmyyyy/$name
#              if [ ! -f "$to_dir/$ddmmyyyy/$new_name"_"$ddmmyyyy"."$ext" ]
#              then
#                  echo -e "t0rvalds : the file $name already exists, copying as $new_name"_"$ddmmyyyy"."$ext"
#                  echo $name $i $to_dir/$ddmmyyyy/$new_name"_"$ddmmyyyy"."$ext >> $log_name


           if [ ! $ext == "" ] #handling files with extensions
           then
                name_orig=`echo $name | sed 's/\.[^.].*$//'`
                name=$name_orig
                j=0
                while [ -f $to_dir/$ddmmyyyy/$name"."$ext ]
                do
                echo -e "t0rvalds : $name"."$ext exists in destination folder"
                let "j=j+1"
                name=$name_orig"_"$j
                done
                cp -p $i /tmp
                mv /tmp/$name_orig"."$ext /tmp/$name"."$ext
                mv /tmp/$name"."$ext $to_dir/$ddmmyyyy
                echo -e "t0rvalds : copying $name_orig.$ext as $name"
                let "transfers_made=transfers_made+1"
                echo $i >> .files_moved
                echo -e "${txtylw}$name_orig.$ext${txtwht}       $i      $to_dir/$ddmmyyyy/${txtylw}$name.$ext${txtwht}     ${txtpur}`date '+%T '`${txtwht}" >> $log_name
                echo -e "${txtylw}$name_orig.$ext${txtwht}       $i      $to_dir/$ddmmyyyy/${txtylw}$name.$ext${txtwht}     ${txtpur}`date '+%T '`${txtwht}" >> $log_name
                #echo "${txtylw}$name${txtwht}       $i        $to_dir/ext_$ext/${txtylw}$name${txtwht}     ${txtpur}`date '+%T '`${txtwht}">> $log_name
                #echo "${txtylw}$name${txtwht}       $i        $to_dir/ext_$ext/${txtylw}$name${txtwht}     ${txtpur}`date '+%T '`${txtwht}">> $log_name
            else
                name_orig=$name
                j=0
                while [ -f $to_dir/$ddmmyyyy/$name ]
                do
                    echo -e "t0rvalds : $name exists in destination folder"
                    let "j=j+1"
                    name=$name_orig"_"$j
                done
                cp -p $i /tmp
                mv /tmp/$name_orig /tmp/$name
                mv /tmp/$name $to_dir/$ddmmyyyy
                echo -e "t0rvalds : copying $name_orig as $name"
                let "transfers_made=transfers_made+1"
                echo $i >> .files_moved
                echo -e "${txtylw}$name_orig${txtwht}      $i      $to_dir/$ddmmyyyy/${txtylw}$name${txtwht}   ${txtpur}`date '+%T '`${txtwht}" >> $log_name
                echo -e "${txtylw}$name_orig${txtwht}      $i      $to_dir/$ddmmyyyy/${txtylw}$name${txtwht}   ${txtpur}`date '+%T '`${txtwht}" >> $log_name
           fi

           else

           echo -e "t0rvalds : copying $name to folder $ddmmyyyy"
           cp -p $i $to_dir/$ddmmyyyy
           let "transfers_made=transfers_made+1"
           echo $i >> .files_moved
           #echo $name $i $to_dir/$ddmmyyyy/$name `date '+%T '`>> $log_name
           #echo $name $i $to_dir/$ddmmyyyy/$name `date '+%T '`>> $log_name
           echo -e "${txtylw}$name${txtwht}      $i      $to_dir/$ddmmyyyy/${txtylw}$name${txtwht}   ${txtpur}`date '+%T '`${txtwht}" >>        $log_name
           echo -e "${txtylw}$name${txtwht}      $i      $to_dir/$ddmmyyyy/${txtylw}$name${txtwht}   ${txtpur}`date '+%T '`${txtwht}" >>        $log_name
           fi
       else
           echo -e "t0rvalds : making directory $ddmmyyyy"
           mkdir $to_dir/$ddmmyyyy
           let "folders_made=folders_made+1"
           echo -e "t0rvalds : copying $name to folder $ddmmyyyy"
           cp -p $i $to_dir/$ddmmyyyy
           let "transfers_made=transfers_made+1"
           echo $i >> .files_moved
           echo -e "${txtylw}$name${txtwht}      $i      $to_dir/$ddmmyyyy/${txtylw}$name${txtwht}       ${txtpur}`date '+%T '`${txtwht}" >>               $log_name
           echo -e "${txtylw}$name${txtwht}      $i      $to_dir/$ddmmyyyy/${txtylw}$name${txtwht}       ${txtpur}`date '+%T '`${txtwht}" >>               $log_name
       fi
       echo $to_dir/$ddmmyyyy >> .folder_list
   fi
   done
   fi
   #############################################################################|


#log generation
echo -e "{$txtcyn}-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^"
echo -e "|                              The Log                               |"
echo -e  "-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^{$txtwht}"
echo -e "Total New Folders Made : $folders_made"
echo -e "Total Moves : $transfers_made"
for i in `cat .folder_list 2>/dev/null | sort |uniq`;
do
    folder_name=`echo $i | awk 'BEGIN{FS="/"} {print $NF}'`
    echo -e "The folder $folder_name now has `ls $i | wc -l` files."
done
##################################################################################|

 echo -e "\nhandling exit : "
if [ $del_flag = 1 ]
then
    echo '-d : deleting organized files'
fi
#-d option handler
if [ $del_flag = 1 ]
then
    for i in `cat .files_moved 2>/dev/null` ;
    do
        echo -e "removing file $i..."
        rm $i
    done
fi
##################################################################################|

#deletingTemporaries
echo -e "deleting temporary files..."
if [ -f .folder_list ] ;
then
    rm .folder_list
fi

if [ -f .files_moved ] ;
then
    rm .files_moved
fi

if [ -f .exclusions_list ];
then
    rm .exclusions_list
fi

for i in `find . -type d -name "*.zip(unpack)" 2> /dev/null `;
do
    rm -rf $i 2> /dev/null
done

##################################################################################|

echo -e $options_string
#bye
echo -e "${txtylw}-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^"
echo -e "|                                Bye!                                |"
echo -e "-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^${txtwht}"

###################################################################################|
#stop music?
echo -e "process completed, stop music or vibin' ? [yes/no]"
read music_flag
if [ $music_flag = "yes" ];
then
kill -9 $music_pid
fi
##################################################################################|
#helper code
tree $from_dir
tree $to_dir
more $log_name