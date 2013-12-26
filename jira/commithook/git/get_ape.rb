# Itay Shmool - 26.12.13
# this script is running from cron , pulls the "html-experiments" slug , and for each repo
# set web hook to trigger Jira on push
# usage :
#
# /var/www/gitorious/script/runner -e production /var/www/gitorious/jira/get_ape.rb html-experiments

slug = ARGV[2]
puts "slug is #{slug}"

project = Project.find_by_slug "#{slug}"
repo_map = project.repositories.map(&:name)


puts project.inspect
repo_map.each do |e|

repository = project.repositories.find_by_name "#{e}"

#check is repository is valid
if repository.nil?
  puts "There is no repo #{e}"
  next
end

# check if repository already has hook set
hook_exist = repository.hooks
if hook_exist.size == 0
  puts "no hook on #{e} ... set the hook"
else
   puts "there is already an hook on #{e}"

 next
end


hook = repository.hooks.build
hook.user = repository.user
hook.url = "http://itayjiraapp.appspot.com/itayjiraapp"
res = hook.save!
puts res

result = Net::HTTP.get(URI.parse("http://itayjiraapp.appspot.com/itayjiraapp?sethook=#{e}"))
   puts result

end

