use LWP::Simple;

#=================================================================
#  createAPEresposInJira.pl
#  
#  get number of new Respos in App Engine DB
#  while (all new repos were created in Jira) :
#  1. get one respo from DB
#  2. create in Jira 
#
#





       
        sub getNumberOfnewAPEExperiments
        {

        my $url = "http://itayjiraapp.appspot.com/intreducenewexperiment?new";
		my $content = get($url);
		die "Can't GET $url" if (! defined $content);
		print "number of new APE experiments:$content";
		return $content; 

        }


		sub getOneExp()
		{
		
		
		my $url = "http://itayjiraapp.appspot.com/intreducenewexperiment?getone";
		my $content = get($url);
		die "Can't GET $url" if (! defined $content);
		
		return $content;
		}

		
		sub createExp()
		{
		my $exp_string=$_[0];
		#/exp_ape.pl -repo=git@git.wixpress.com:html-experiments/pixel_perfect_editor_ui.git  -expdir=deployment/  -jira_project=APE -build_name=pixel_perfect_editor_ui
		
		 my @values = split(',', $exp_string);


  			
  			my $repo=$values[0];
  			my $expdir=$values[1];
  			my $jira_project=$values[2]; 
  			my $build_name=$values[3];
  			
  			my $cmd = "perl /var/tmp/exp/createOneApeExp.pl -repo=$repo  -expdir=$expdir  -jira_project=$jira_project -build_name=\"$build_name\"";
  			print "$cmd\n";
  			system($cmd);

		}


 $count = &getNumberOfnewAPEExperiments();

 while ($count >= 1) {
 	my $exp = &getOneExp();
    &createExp($exp);
 #print "$exp \n";
 $count--;
 }
 


