require 'json'
require 'git'

class PromoteReleaseCandidate


  def self.make_permalink()
    json = JSON.parse('{
          "GitRepo" : "git@github.com:IMQS/mm.git",
          "DockerServiceName" : "imqs/mm:ITOOLS603-MF-CreateReleaseCandidate",
          "DockerBuild" : "sudo docker build -t imqs/mm --build-arg netrc=\"$(cat ~/.netrc)\" --build-arg ssh_prv_key=\"$(cat ~/.ssh/id_rsa)\" --build-arg ssh_pub_key=\"$(cat ~/.ssh/id_rsa.pub)\" ."
}')

    release_candidates = []
    release_candidates[0] = json

    release_candidates.each{|repo|
      # Store the json oblects in varaibles
      repository_name = repo["GitRepo"]
      docker_service_name = repo["DockerServiceName"]
      docker_buils_command = repo["DockerBuild"]

      #Clone repo locally
      # Todo : Get from json
      Git.clone(repository_name, 'mm')

      # Get the build number


      # If there is no build number <tag> : Create one.

      # Else increment existing

      # Then build
    }
  end
end

PromoteReleaseCandidate.make_permalink()