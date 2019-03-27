require 'json'
require_relative 'ImqsGit'

class PromoteReleaseCandidate
  # The main runner method to be called
  def self.prepare_release_candidate
    release_candidates = fetch_release_candidates ('releaseCandidates.json')
    manifest_json = []
    #Starting release candidate process.
    release_candidates.each { |repo|
      # Get properties from json file.
      docker_service_name = repo['DockerServiceName']
      docker_build_command = repo['DockerBuild']
      repository_name = repo['GitRepo']
      # Get the name of the branch. Should always be master, but adding this option for development purposes.
      branch = docker_service_name[docker_service_name.index(':')+ 1..docker_service_name.length]
      # Get the version. Versioning calculations happen in here. If the version stays the same the code will successfully exit(0)
      version = prepare_version(repository_name, branch)
      # ToDo : Set condition not to build if nothing has changed.
      prepare_docker_image(docker_build_command)
      # Create a service hash to be used in json object, for the manifest file.
      temp_hash = create_service_hash(docker_service_name, version)
      manifest_json.push(temp_hash) }

    # Manifest file created here.
    create_manifest_file(manifest_json)
  end

  private
  # Creates a physical file called manifest.json
  # Writes to the the above mentioned file, the content of the hash as json.
  # @param : Ruby hash.
  def self.create_manifest_file(manifest_json)
    file_name = '../manifest.json'
    File.open(file_name, 'w') do |f|
      f.write(manifest_json.to_json)
    end
  end

  # Build the docker image and pushes if successful.
  # @param : A docker build command.
  def self.prepare_docker_image(docker_build_command)
    std_out = `#{docker_build_command} 2>&1`
    puts (std_out)
    # ToDo : Docker Push
  end

  # Creates a ruby hash containing the following
  # @param1 : The docker image service name.
  # @param2 : The version number as an integer, of the image.
  def self.create_service_hash(docker_service_name, version)
    {
        :ServiceName => docker_service_name,
        :Version => version
    }
  end

  # Fetch the release candidated from a specified json file.
  # @param :
  def self.fetch_release_candidates (file)
    json_from_file = File.read(file)
    return JSON.parse(json_from_file)
  end

  # Does the major version calculation, if anything has changed.
  #
  def self.prepare_version(repository_name, branch)
    repository = GitRepository.new(repository_name, branch)
    puts (repository.version)
    if (repository.head) == (repository.fetch_revision(repository.version))
      puts "Nothing has changed. Keeping #{repository.version}"
      exit(0)
    end

    return provide_version(repository)
  rescue ImqsGitError => error
    puts("#{error.message} : #{error.backtrace}")
    exit (1)
  end

  def self.provide_version(repository)
    if repository.version.to_s.include? 'fatal: No names found, cannot describe anything'
      repository.tag('v1.0')
    else
      increment_version(repository) if repository.version.tr("\n", '').tr('v', '').is_float?
    end
  end

  def self.increment_version(repository)
    version_number = repository.version.tr("\n", '').tr('v', '').to_i
    version_number = (version_number.to_i + 1).to_f
    repository.tag("v#{version_number}")
    return version_number
  end
end

class String
  def is_float?
    /\A[+-]?\d+[.]\d+\z/ === self
  end
end

PromoteReleaseCandidate.prepare_release_candidate