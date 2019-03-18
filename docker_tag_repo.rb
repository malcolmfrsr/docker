require 'json'
require_relative 'imqsgit'

class PromoteReleaseCandidate
  def self.prepareReleaseCandidate()
    release_candidates = fetch_release_candidates ("releaseCandidates.json")

    puts ("We are about to itterate throu the json objects.")
    release_candidates.each { |repo|
      # Store the json objects in varaibles
      docker_service_name = repo["DockerServiceName"]
      docker_build_command = repo["DockerBuild"]
      repository_name = repo["GitRepo"]

      branch = docker_service_name[docker_service_name.index(":")+ 1..docker_service_name.length]
      prepare_version(repository_name, branch)

      # Then build
      puts ("ToDo : do a docker build here")

      # Then build
      puts ("ToDo : create manifest")
    }
  end

  def self.prepare_version(repository_name, branch)
    repository = GitRepository.new(repository_name, branch)
    # TODO : I think I need to move this internally and surface as an attribute. (Thinking of the negative implication.)
    if ((repository.head) == (repository.fetch_revision(repository.version)))
      puts "Nothing has changed. Keeping #{repository.version}"
      return repository.version
    end

    # TODO : This could also be a possible attr on the repository class.
    if (repository.version.to_s.include? "fatal: No names found, cannot describe anything")
      repository.tag("v1.0")
    else
      # TODO : This as well ?
      if repository.version.tr("\n", "").tr("v", "").is_float?
        version_number = repository.version.tr("\n", "").tr("v", "").to_i
        version_number = (version_number.to_i + 1).to_f
        repository.tag("v#{version_number}")
        return version_number
      end
    end
  end

  def self.fetch_release_candidates (file)
    json_from_file = File.read(file)
    return JSON.parse(json_from_file)
  end
end

class String
  def is_float?
    /\A[+-]?\d+[.]\d+\z/ === self
  end
end

PromoteReleaseCandidate.prepareReleaseCandidate()