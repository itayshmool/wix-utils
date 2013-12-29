#!/usr/bin/perl
use POSIX;
use Getopt::Std;
use Getopt::Long;
use URI::Escape;
use File::Path;
use warnings;


       #$0 - location of current exp list for this artifact
       sub getCurrentExpMap
        {

	        my $current=$_[0];
                my %current_exp_hash = ();

                #"/var/tmp/exp/current.exp"
                open (IN, $current)  or die $!;

                @lines = <IN>;
                #seek IN,0,0;

                foreach $line (@lines)
                {
                    chomp($line);
                    $current_exp_hash{ $line} = $line;
                }

                close IN;

                return %current_exp_hash;

        }

        # $0 - location of pom.xml file
        sub getCurrentSnapShot
        {

        	my $pom=$_[0];
            	my $version = `cat $pom | grep SNAPSHOT |  head -1`;
             	# my $version = `cat /var/tmp/exp/hclient/bootstrap/pom.xml | grep SNAPSHOT |  head -1`;


                my $find = "<version>";
                my $replace = "";

                $find = quotemeta $find; # escape regex metachars if present

                $version =~ s/$find/$replace/g;

                my @values = split('-', $version);

                my $ret=trim($values[0]);
		return $ret;

        }

	sub create_new_experiment()
   	{
        	my $file = $_[0];
        	my $full_exp_dir=$_[1];
		my $snapshot=$_[2];

        	write_log("Experiment $file is new --> Create it ...\n");

	 	$id = $file;
    		$id =~ s/.json//g;
    		$info = "$id,$snapshot,$jira_project";

    		$url =  "http://itayjiraapp.appspot.com/updatesingleexperiment?info=$info";

    		$cmd = "curl -v -D- -X POST --data @".$full_exp_dir."$file -H Content-Type:application/json " .$url;
    		write_log("$cmd \n\n\n");
    		
			
		 if ($DEBUG != 1)
                 {
                    system($cmd);
                 }


    	}	


	 sub merge_exp
   	 {

        	my  $current_exp=$_[0];
       		my  $snapshot=$_[1];

	        # "merge" experiment , it was at the old map but not at the new one
        	write_log("Experiment $current_exp  Does not exists also in new map -->  merge it\n");

	   	$id = $current_exp;
    		$id =~ s/.json//g;
         	$info = "$id,$snapshot,$jira_project";

		$url =  "http://itayjiraapp.appspot.com/mergesingleexperiment?info=$info";
         	$cmd = "curl -v -D- -X GET ".$url;
         	write_log($cmd."\n");

		if ($DEBUG != 1)
		{
         	  system($cmd);
		}
    	}


	sub trim($)
	{
        	my $string = shift;
	        $string =~ s/^\s+//;
        	$string =~ s/\s+$//;
	        return $string;
	}

	sub format_build_name($)
	{
		my $build_name=shift;
		$build_name =~ s/ /_/;
		return $build_name;	

	}

	
	sub create_log_file($)

   	{
        	my $snapshot=shift;
		$current_date = `date +"%b-%d-%H:%M"`;
        	chop($current_date);


                my $NEW_LOG_FILE= "$snapshot-$current_date.log";
                print "create new log file : $NEW_LOG_FILE \n\n";
	
        	return $NEW_LOG_FILE;
    	}


	sub write_log($)
	{

		my $log=shift;
		print MY_LOG_FILE $log ;
		print $log;
		
	}
	

	sub get_build_dir($)
	{
		my $repo=shift;
		my @values = split('/', $repo);
		my $last=$values[$#values];
		$last =~ s/.git//g;
		return $last;

	}	
#=========================================== M A I N ======================================================


   	 my $manhelp="\n\n\nexp.pl -repo=<git repository> -expdir=<experiment directory> -jira_project=<jira_project> -build_name=<build name> -pom=<pom.xml full path> \n\n";

	 ## get options from user
    	GetOptions("help" => \$help,
		   "debug" => \$DEBUG,	
	            "repo=s" => \$repo,
	            "jira_project=s" => \$jira_project,
	            "build_name=s" => \$build_name,
	            "pom=s" => \$pom,
 	            "expdir=s" => \$expdir);
 	   
	 if ($help == 1)
   	 {
	    print $manhelp;
	    exit;
   	 }


	  if ($DEBUG == 1)
	  {
             print "\n\n\n *** DEBUG mode *** \n\n\n";
          }


	my $path="/var/tmp/exp/";
	my $build_dir=get_build_dir($repo);
	chdir $path;
	my $build_name_orig = $build_name;
	$build_name=format_build_name($build_name);	

#	my $repo = "git@"."git.wixpress.com:html-client/tpa-client.git";
	my $clone = "git clone $repo";
	# clone project
   	# build it if needed
    	#system($path.$script);
	chdir $build_dir;
	$pull = `git pull`;
	if ($pull =~ "Already up-to-date")
	{
		print "pull $repo without changes ... exit ...\n";
		exit(0);

	}
	chdir $path;
	
#	system($clone);

	my $current_list = $path . "current.exp" . ".$build_name";

	my $full_path_exp_dir = $path.$expdir;
  	# build a map of the current experiments from the previous run
	my %current_exp_hash = getCurrentExpMap($current_list);
	my %new_exp_hash = ();
 
   	my $snapshot = getCurrentSnapShot($path.$pom);
	my $snapshot_orig_before = $snapshot;
    	$snapshot = uri_escape("$build_name_orig"."-".$snapshot);
	print "current snapshot $snapshot ***\n\n";
	

	$log_file=create_log_file($build_name.$snapshot_orig_before);

	open (MY_LOG_FILE, ">> $log_file");
    	print MY_LOG_FILE "start new run:$repo\n,$jira_project\n,$build_name\n,$expdir\n";
	print MY_LOG_FILE $pull;
	opendir(DIR, $full_path_exp_dir) or die $!;


	#=========================
   	# handle new experiments
	#=========================	
    	while (my $file = readdir(DIR)) 
	{

        	# We only want files
        	next unless (-f "$full_path_exp_dir/$file");

	        # Use a regular expression to find files ending in .txt
        	next unless ($file =~ m/\.json$/);
	    
	    	$new_exp_hash{$file} = $file;
    
		if (exists $current_exp_hash{$file})
		{
           	  #print "Experiment $file Exist --> Nothing to do\n";
		
		}else
		{
		    &create_new_experiment($file,$path.$expdir,$snapshot);
		}
				
   	 }	

    	closedir(DIR);
	
	#=========================
	# "merge" old experiments
	#=========================
	for my $key ( keys %current_exp_hash )
	{
		my $current_exp = $current_exp_hash{$key};
		
		if (exists $new_exp_hash{$current_exp} )
		{
	                #print "Experiment $current_exp  exists also in new map --> Do not merge\n";

		}else
		{
		    # "merge" experiment , it was at the old map but not at the new one
		     merge_exp($current_exp,$snapshot);
		}
			
	}

	
	# save current list as orig
	$cp_current_list = "cp ".$current_list." ".$current_list.".orig";
     	system($cp_current_list);

	# save current dir files as current list
    	$create_new_current_list = "ls ".$full_path_exp_dir. "> ".$current_list;
     	system($create_new_current_list);

	$diff_cmd="diff $current_list $current_list.orig";
	$diff = `$diff_cmd`;
	print MY_LOG_FILE "the diff between current list and previous list:\n$diff";
# 	system("rm -Rf /var/tmp/exp/hclient");
	close(MY_LOG_FILE);
   	exit 0;

	#====================================================
	
	
	
