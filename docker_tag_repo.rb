require ('json')

class PromoteReleaseCandidate


  def self.make_permalink()
          json = JSON.parse('{
          "GitRepo" : "git@github.com:IMQS/mm.git",
          "DockerServiceName" : "imqs/mm:ITOOLS603-MF-CreateReleaseCandidate",
          "DockerBuild" : "sudo docker build -t imqs/mm --build-arg netrc=\"$(cat ~/.netrc)\" --build-arg ssh_prv_key=\"$(cat ~/.ssh/id_rsa)\" --build-arg ssh_pub_key=\"$(cat ~/.ssh/id_rsa.pub)\" ."
          "LatestVersionMarkedForRelease"
}')

    puts (json)
  end
end

PromoteReleaseCandidate.make_permalink()