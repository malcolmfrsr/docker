require 'json'

class PromoteReleaseCandidate
  def self.make_permalink()
    json = JSON.parse('{
          "GitRepo" : "git@github.com:IMQS/mm.git",
          "DockerServiceName" : "imqs/mm:ITOOLS603-MF-CreateReleaseCandidate",
          "DockerBuild" : "sudo docker build -t imqs/mm --build-arg netrc=\"$(cat ~/.netrc)\" --build-arg ssh_prv_key=\"$(cat ~/.ssh/id_rsa)\" --build-arg ssh_pub_key=\"$(cat ~/.ssh/id_rsa.pub)\" ."
}')

    puts ("start the scriopt.")
    release_candidates = []
    release_candidates[0] = json

    puts ("We are about to itterate throu the json objects.")
    release_candidates.each { |repo|
      # Store the json oblects in varaibles
      repository_name = repo["GitRepo"]
      docker_service_name = repo["DockerServiceName"]
      docker_buils_command = repo["DockerBuild"]

      #Clone repo locally
      puts ("This is the where we specify the directory.")
      repo_dir = 'mm'

      if !File.directory?(repo_dir)
        puts `mkdir #{repo_dir}`
        puts `cd #{repo_dir}`
      end
       puts `git clone #{repository_name}`

      # Get the build number
      tag = `git describe --tags 2>&1`
      puts tag
      if (tag.to_s.include? "fatal: No names found, cannot describe anything")
        puts(`git tag 1.0`)
      else
        if tag.tr("\n", "").is_float?
          version_number = tag.tr("\n", "").to_f
          version_number = version_number + 1
          puts(`git tag #{version_number}`)
        end
      end

      # Then build
      puts (`#{docker_buils_command}`)
    }
  end
end

class String
  def is_float?
    /\A[+-]?\d+[.]\d+\z/ === self
  end
end

PromoteReleaseCandidate.make_permalink()