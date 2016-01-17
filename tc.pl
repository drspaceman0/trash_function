#!/usr/bin/perl
#Eric Marsh
#CS270
#3/27/2015

use File::Path qw(make_path);
use feature qw(switch);
use Cwd;
use File::Copy;
use File::Compare;
use Time::HiRes;

$USER_NAME = "mars2681";
$TRASH_PATH = "/home/$USER_NAME/trashcan"; 
$DIR = getcwd; #current directory

sub move_file {
	# $_[0] == dir with file. $_[1] == file. $_[2] == dir to be moved to

	if(check_dir_for_file($_[0], $_[1])){   #check current directory for file
		#print "File has been found\n";
		$SOURCE_FILE = $_[0] . "/" . $_[1];
		$DESTINATION_FILE = $_[2] . "/" . $_[1];
		if(check_dir_for_file($_[2], $_[1])){
			#print "File with same name in destination directory!\n";
			
			if(compare($SOURCE_FILE,$DESTINATION_FILE) == 0){
				#print "The two files are the same!\n";
				unlink($DESTINATION_FILE); #delete old copy
				#continues on to move()
			}
			else{
				#print "The two files are different inside!\n";
				
				$OLD_FILE = $_[1];
				#checking file name for version extension
				if($_[1] =~ s/(\d+)$/$1 + 1/e){
					#print "File has a version extension and it has been incremented.\n";
				}			
				else{
					#print "No file extension found.\n";
					$VERSION_NUM = 1;
					$_[1] = $_[1] . "." . $VERSION_NUM;
				}
				#print "The new file name will be:  $_[1]\n";
				$SOURCE_FILE = $_[0] . "/" . $_[1]; #renaming source path accordingly
				$DESTINATION_FILE = $_[2] . "/" . $_[1]; #renaming dest. path accordingly
				
				#print "Now renaming new file with a version number.\n";
				rename ( $OLD_FILE, $_[1] );
				
				#continues on to move()
			}
		}
		move($SOURCE_FILE, $DESTINATION_FILE);# or die "The move operation failed: $!"; #Move file to trashcan
	}
	else{
		print "File does not exist in current directory\n";
	}
}

sub check_dir_for_file {
	$i = index(`ls $_[0]`, $_[1]);
	if ($i == -1) 
		{return 0;}
	else
		{return 1;}

}

sub empty_trash {
	#print "Emptying trashcan.\n";
	system("rm -rf $TRASH_PATH/*");  
}

##################
#Main starts here#
##################
if(check_dir_for_file("/home/$USER_NAME/", "trashcan")){
	#print "trashcan found\n";
}
else{
	print "Creating directory: $TRASH_PATH\n";
    make_path($TRASH_PATH);	
}	

#process arguments
$INTERACT_TRASH = 0;
$RETRIEVE_TRASH = 0;
foreach my $ARG(@ARGV){
	#print "$ARG\n";
	given($ARG){
	
		when(-d $ARG){
			#print "Argument is a directory.\n";
			$DEST = $ARG . "/" . "trashcan";
			system("mv $TRASH_PATH $DEST");
			$TRASH_PATH = $DEST;
			print "The trashcan directory now is : $TRASH_PATH\n";
			next;
		}
	
		when("-r"){
			#print "Retreive option\n";
			$RETRIEVE_TRASH = 1;
			next;
		}
		when("-l"){
			#print "List option\n";
			print `ls $TRASH_PATH`;
			next;
		}
		when("-i"){
			#print "Interactive option\n";
			$INTERACT_TRASH = 1;
			next;
		}
		when("-e") {
			#print "Empty option\n";
			empty_trash;
			next;
		}
		
		
		when(-f $ARG) #check if argument is a file
		{
			#print "Argument is a word.\n";
			
			if ($RETRIEVE_TRASH == 1){
				print "About to retrieve file...\n";
				move_file($TRASH_PATH, $ARG, $DIR);
				exit 1;
			}			
			
			if ($INTERACT_TRASH == 1){
				#print "Now prompting user ( -i command.)\n";
				print "Are you sure you want to trash $ARG?: ";
				$INPUT = <STDIN>;
				if($INPUT =~ "yes" or $INPUT =~ "y"){
					print "\n";
					#Goes on to move_file
				}
				else{
					#do nothing
					next;
				}	
			}
			
			#print "About to move file: $ARG\n";
			move_file($DIR,$ARG,$TRASH_PATH);
			next;
		}
		
    }
}

	exit 1;