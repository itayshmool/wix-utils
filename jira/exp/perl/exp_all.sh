#!/bin/bash
/var/tmp/exp/exp.pl -repo=git@git.wixpress.com:html-client/hclient.git -expdir=hclient/bootstrap/src/main/experiment-descriptors/ -jira_project=WOH -build_name="HTML Client" -pom=/hclient/bootstrap/pom.xml
/var/tmp/exp/exp.pl -repo=git@git.wixpress.com:html-client/tpa-client.git -expdir=/tpa-client/src/main/experiment-descriptors/ -jira_project=TPA -build_name="TPA Client" -pom=/tpa-client/pom.xml

/var/tmp/exp/exp.pl -repo=git@git.wixpress.com:html-client/wixapps.git -expdir=/wixapps/src/main/experiment-descriptors/ -jira_project=WIXAPPS -build_name="Wixapps" -pom=/wixapps/pom.xml
