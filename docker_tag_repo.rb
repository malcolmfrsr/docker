require ('json')

class PromoteReleaseCandidate


  def self.make_permalink()
          json = JSON.parse('{
          "GitRepo" : "git@github.com:IMQS/mm.git",
          "DockerServiceName" : "imqs/mm:ITOOLS603-MF-CreateReleaseCandidate",
          "DockerBuild" : "sudo docker build -t imqs/mm --build-arg netrc=\"$(cat ~/.netrc)\" --build-arg ssh_prv_key=\"$(cat ~/.ssh/id_rsa)\" --build-arg ssh_pub_key=\"$(cat ~/.ssh/id_rsa.pub)\" ."
}')


    # Store the json oblects in varaibles
    repo = json["GitRepo"]
    docker_service_name = json["DockerServiceName"]
    docker_buils_command = json["DockerBuild"]
  end
end

PromoteReleaseCandidate.make_permalink()