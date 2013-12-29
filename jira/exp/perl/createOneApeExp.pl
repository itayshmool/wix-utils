	#!/usr/bin/perl


	use POSIX;
	use Getopt::Std;
	use Getopt::Long;
	use URI::Escape;
	use File::Path;



		 

		# get current snapshot from POM file
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
			my $id = $_[3];

			write_log("Experiment $id  is new --> Create it ...\n");


			$id = uri_escape($id);
			$id =~ s/\\|\R//g;
			$info = "$id,$snapshot,$jira_project";

			$url =  "http://itayjiraapp.appspot.com/updatesingleexperiment?info=$info";

			$cmd = "curl -v -D- -X POST --data @".$full_exp_dir."$file -H Content-Type:application/json " .$url;
			write_log("** $cmd ***\n\n\n");


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

				$id = $current_exp;
				$id =~ s/.json//g;
				$info = "$id,$snapshot,$jira_project";

				$url =  "http://itayjiraapp.appspot.com/mergesingleexperiment?info=$info";
				$cmd = "curl -v -D- -X GET ".$url;
				write_log($cmd."\n");

				if ($DEBUG != 1)
				{
				 # system($cmd);
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


		 # nCreateOneApeExp.pl -repo=git@git.wixpress.com:html-experiments/slideshowgallerynbc.gitgit@git.wixpress.com:html-experiments/
		 #          	 	   -expdir=deployment/
		 #            		   -jira_project=APE
		 #           		    -build_name=slideshowgallerynbc



		 my $manhelp="\n\n\nCreateOneApeExp.pl -repo=<git repository> -expdir=<experiment directory> -jira_project=<jira_project> -build_name=<build name> \n\n";


		 ## get options from user
			GetOptions("help" => \$help,
			   "debug" => \$DEBUG,
			   "repo=s" => \$repo,
					"jira_project=s" => \$jira_project,
					"build_name=s" => \$build_name,
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



		my $working_directory = "/var/tmp/exp";
		chdir $working_directory;


		my $clone = "git clone $repo";
		system($clone);
	
		$repo_dir = &get_build_dir($repo);
	
	
	
		chdir $repo_dir;
	
	


		my $pom = $working_directory."/".$repo_dir."/pom.xml";
		my $snapshot = getCurrentSnapShot($pom);

		$build_name =~ s/\\|\n//g; 
		$snapshot =~ s/\\|\n//g;
		$snapshot = uri_escape("$build_name"."-".$snapshot);
		
		print "current snapshot $snapshot ***\n\n";
		
		my $file="descriptor.json";

		&create_new_experiment($file,$working_directory."/".$repo_dir."/".$expdir,$snapshot,$build_name);

