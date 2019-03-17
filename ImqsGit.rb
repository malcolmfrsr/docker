##
#Creats a git repositoy object, which has various git commands
# @param : Valid git repository ie git@github.com:<orginization>/<repository>.git.
# @param : Name of the branch you would like to checkout on clone
# @param : Optional argument that the local path of the repository.
class GitRepository
  attr_reader :branch, :head, :name, :version
  VERSION_PREFIX = 'v'.freeze

  def initialize(repository_name, branch, folder="")
    #Fetch the folder from the name.
    if folder.empty?
      repository_folder = repository_name[repository_name.index("/")+1..repository_name.index(".git") - 1]
    else
      repository_folder = folder
    end

    if !File.directory?(repository_folder)
      cmd = "git clone -b #{branch} #{repository_name}"
      system(cmd, out: $stdout, err: :out)
      gitrepo = Dir.mkdir(repository_folder)
    end
    gitrepo = Dir.chdir(repository_folder)

    @branch = branch
    @head = fetch_revision("HEAD")
    @name = repository_name
    @version = fetch_latest_tag
  end

  # Fetch the revision specified.
  # @param : Takes either HEAD or <tags> as string.
  # @returns : The revsion number as a string.
  def fetch_revision(commit)
    return `git rev-parse #{commit}`.tr("\n", "")
  end

  # Fetches all the tags for repository branch.
  def fetch_tags
    clean_tags = []
    tag("-l \"#{VERSION_PREFIX}*\"  --sort=-#{VERSION_PREFIX}:refname").split("\n").each { |vtag|
      clean_tags.push(vtag) if vtag.match(/\A[v]\d+[.]\d+\z/)
    }

    return clean_tags
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