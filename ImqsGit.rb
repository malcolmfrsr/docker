##
#Creats a git repositoy object, which has various git commands
# @param : Valid git repository ie git@github.com:<orginization>/<repository>.git.
# @param : Name of the branch you would like to checkout on clone
# @param : Optional argument that the local path of the repository.
class GitRepository
  attr_reader :branch, :head, :name, :version
  VERSION_PREFIX = 'v'.freeze

  def initialize(repository_name, branch, folder="")
    # Fetch the folder from the name, if it is not specified.
    if folder.empty?
      repository_folder = repository_name[repository_name.index("/")+1..repository_name.index(".git") - 1]
    else
      repository_folder = folder
    end

    # If the directory does not exist, assume that it has not been cloned.
    if !File.directory?(repository_folder)
      cmd = "git clone -b #{branch} #{repository_name}"
      system(cmd, out: $stdout, err: :out)
      gitrepo = Dir.mkdir(repository_folder)
    end
    gitrepo = Dir.chdir(repository_folder)

    @branch = branch # The branch that git repo will be on.
    @head = fetch_revision("HEAD") # The current head.
    @name = repository_name # The name of the repossitory.
    @version = fetch_latest_tag # The last tagged version.
  end

  # Fetch the revision specified.
  # @param : Takes either HEAD or <tags> as string.
  # @returns : The revsion number as a string.
  def fetch_revision(commit)
    return `git rev-parse #{commit}`.tr("\n", "")
  end

  # Tags a git reopsitory and and outputs to stdout.
  # @param : accepts valid tag arguments.
  # @returns standard out.
  def tag(arg="")
    return `git tag #{arg} 2>&1`
  end

  # Does a 'git push'.
  # @param : accepts valid tag arguments.
  # @returns : standard out.
  def push(arg="")
    return `git push #{arg} 2>&1`
  end

  # Fetches all the valid tags for repository branch.
  # Validates if the version name conforms to v*.*
  # ToDo : discuss version tag formatting.
  # @param : accepts valid tag arguments.
  def fetch_tags (arg)
    clean_tags = []
    tag(arg).split("\n").each { |vtag|
      clean_tags.push(vtag) if vtag.match(/\A[v]\d+[.]\d+\z/)
    }
    # contains tags that conform to format : discuss
    return clean_tags
  end

  # Fetches the last version.

  def fetch_latest_tag
    version_array = fetch_tags("-l \"#{VERSION_PREFIX}*\"  --sort=-#{VERSION_PREFIX}:refname")
    return version_array[0]
  end
end