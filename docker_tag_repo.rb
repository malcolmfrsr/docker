require 'json'

class PromoteReleaseCandidate
  def self.prepareReleaseCandidate()
    release_candidates = fetch_release_candidates ("releaseCandidates.json")

    puts ("We are about to itterate throu the json objects.")
    release_candidates.each { |repo|
      # Store the json oblects in varaibles
      docker_service_name = repo["DockerServiceName"]
      docker_build_command = repo["DockerBuild"]
      repository_name = repo["GitRepo"]

      branch = docker_service_name[docker_service_name.index(":")+ 1..docker_service_name.length]
      prepare_version(repository_name, branch)

      # Then build
      puts (`#{docker_build_command}`)
    }
  end

  def self.prepare_version(repository_name, branch)
    repository = GitRepository.new(repository_name, branch)
    tag = repository.fetch_latest_tag
    puts tag
    if (tag.to_s.include? "fatal: No names found, cannot describe anything")
      puts(`git tag v1.0`)
    else
      if tag.tr("\n", "").tr("v", "").is_float?
        version_number = tag.tr("\n", "").tr("v", "").to_f
        version_number = version_number + 1
        puts(`git tag v#{version_number}`)
      end
    end
  end

  def self.fetch_release_candidates (file)
    json_from_file = File.read(file)
    return JSON.parse(json_from_file)
  end
end

class GitRepository
  VERSION_PREFIX = 'v'.freeze

  def initialize(repository_name, branch)
    #ToDo : fetch repo folder from the
    repository_folder = repository_name[repository_name.index("/")+1..repository_name.index(".git") - 1]

    if !File.directory?(repository_folder)
      cmd = "git clone -b #{branch} #{repository_name}"
      system(cmd, out: $stdout, err: :out)
      gitrepo = Dir.new(repository_folder)
    end
    gitrepo = Dir.chdir(repository_folder)

    return gitrepo
  end

  # Fetches git tags from the command line and outputs as stdout
  def fetch_tags
    tag = tag("-l \"#{VERSION_PREFIX}*\"  --sort=-#{VERSION_PREFIX}:refname").split("\n")
    return tag
  end

  def fetch_latest_tag
    version_array = fetch_tags
    return version_array[0]
  end

  def tag(arg="")
    return `git tag #{arg} 2>&1`
  end

  def push(arg="")
    return `git push #{arg} 2>&1`
  end
end

class String
  # ToDO : modify to include "v"
  def is_float?
    /\A[+-]?\d+[.]\d+\z/ === self
  end
end

PromoteReleaseCandidate.prepareReleaseCandidate()