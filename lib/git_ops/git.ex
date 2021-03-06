defmodule GitOps.Git do
  @moduledoc """
  Helper functions for working with `Git` and fetching the tags/commits we care about.
  """
  @spec init!() :: Git.Repository.t()
  def init!() do
    Git.init!(File.cwd!())
  end

  @spec commit!(Git.Repository.t(), [String.t()]) :: String.t()
  def commit!(repo, args) do
    Git.commit!(repo, args)
  end

  @spec tag!(Git.Repository.t(), String.t() | [String.t()]) :: String.t()
  def tag!(repo, current_version) do
    Git.tag!(repo, current_version)
  end

  @spec get_initial_commits!(Git.Repository.t()) :: [String.t()]
  def get_initial_commits!(repo) do
    messages =
      repo
      |> Git.log!(["--format=%B--gitops--"])
      |> String.split("--gitops--")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&Kernel.==(&1, ""))

    ["chore(GitOps): Add changelog using git_ops." | messages]
  end

  @spec tags(Git.Repository.t()) :: [String.t()]
  def tags(repo) do
    tags =
      repo
      |> Git.tag!()
      |> String.split("\n")

    if Enum.empty?(tags) do
      raise """
      Could not find an appropriate semver tag in git history. Ensure that you have initialized the project and commited the result.
      """
    else
      tags
    end
  end

  @spec commit_messages_since_tag(Git.Repository.t(), String.t()) :: [String.t()]
  def commit_messages_since_tag(repo, tag) do
    repo
    |> Git.log!(["#{tag}..HEAD", "--format=%B--gitops--"])
    |> String.split("--gitops--")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&Kernel.==(&1, ""))
  end
end
