# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch("SOLIDUS_BRANCH", "main")

# solidus_frontend was extracted and has different versioning
# Use v3.4 branch for solidus_frontend when using newer Solidus versions
frontend_branch = case branch
when "main", "current"
  "v3.4"
when /^v(\d+)\.(\d+)/
  # Extract version numbers and compare
  major, minor = $1.to_i, $2.to_i
  if major > 3 || (major == 3 && minor > 4)
    "v3.4"
  else
    branch
  end
else
  branch
end

gem "solidus", github: "solidusio/solidus", branch: branch
gem "solidus_frontend", github: "solidusio/solidus_frontend", branch: frontend_branch

# Needed to help Bundler figure out how to resolve dependencies,
# otherwise it takes forever to resolve them.
# See https://github.com/bundler/bundler/issues/6677
gem "rails", ">0.a"

# Provides basic authentication functionality for testing parts of your engine
gem "solidus_auth_devise"

case ENV["DB"]
when "mysql"
  gem "mysql2"
when "postgresql"
  gem "pg"
else
  gem "sqlite3", ">= 2.1"
end

gemspec

# Use a local Gemfile to include development dependencies that might not be
# relevant for the project or for other contributors, e.g. pry-byebug.
#
# We use `send` instead of calling `eval_gemfile` to work around an issue with
# how Dependabot parses projects: https://github.com/dependabot/dependabot-core/issues/1658.
send(:eval_gemfile, "Gemfile-local") if File.exist? "Gemfile-local"
