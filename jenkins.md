## Jenkins

### Install

Execute the shell script: `jenkins_install.sh`

Configure a proxy using nginx or apache to http://ci.company.example.com.br(I'll use this URL as example).

### Configure credentials
* http://ci.example.com.br/credential-store/domain/_/newCredentials

### Configure plugins:
* Add Github Plugin, Multi-Branch Project Plugin, AnsiColor Plugin, Slack Plugin and Embeddable Build Status at http://ci.example.com.br/pluginManager/available

### Configure Shell section setting Shell executable
* Use `/bin/bash` at http://ci.example.com.br/jenkins/configure

### Configure GitHub Webhooks
* Navigate to `Webhooks & Services` under `Settings` on the GitHub repository page https://github.com/:company/:projet/
* Click `Configure services` and select the `Jenkins (GitHub plugin)` option
* Enter the address to your Jenkins server http://ci.example.com.br/github-webhook/, check `Active` and update your settings.
* Try it out by pushing a commit to GitHub and verifying that a new build is triggered in Jenkins

### Create a new build configuration
* Access http://ci.example.com.br/view/All/newJob
* Add new item (Build a free-style multi-branch project)

  **GitHub project**: fill with https://github.com/:company/:projet/

  **Execute concurrent builds if necessary** check this options

  **Source Code Management**:

    **Sync Branches Schedule**: H/2 * * * * (every two minutes)

    **Git** check this option

    **Repository URL**: fill with git@github.com:company/project.git

    **Credentials**: select `company-credentials` or the name specified at `Configure credentials`step

    **Include branches**: fill with `*` to include all branchs

  **Build Triggers**:

    Check `Build when a change is pushed to GitHub`

  **Build Environment**:

    Check `Color ANSI Console Output` and select `xterm` from `ANSI color map`

  **Build** (Execute shell):

      #!/bin/bash
      cp /var/lib/jenkins/sample_database.yml config/database.yml

      function clean_up {
        RAILS_ENV=test bundle exec rake db:drop
        
        exit $1
      }

      rvm use 2.2.1 --install
      rvm info
      ruby --version

      gem install bundler --no-rdoc --no-ri
      bundle install

      RAILS_ENV=test bundle exec rake db:create:all
      RAILS_ENV=test bundle exec rake db:migrate
      RAILS_ENV=test bundle exec rake db:test:prepare

      trap clean_up SIGHUP SIGINT SIGTERM

      SPEC_OPTS="--no-drb --format documentation"

      bundle exec rspec spec

      # Capture value returnd by last command
      rspec_status=$?

      clean_up $rspec_status

### Rspec configuration

To get RSpec colours working in Jenkins you have to specify the following in the RSpec configuration block:

      RSpec.configure do |config|
       config.tty = true
      end

This is because the Jenkins shell is a pseudo TTY.

### Slack Integration

To configure integration with Slack https://company.slack.com/services/new/jenkins-ci
