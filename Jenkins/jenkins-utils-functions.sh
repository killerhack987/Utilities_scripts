# source this file and use the functions, download the jenkins-cli.jar first
export JENKINS_SERVER=localhost
export JENKINS_PORT=8080
export JENKINS_USER='admin'
export JENKINS_PASS='admin'
export JENKINS_JOBDIR="jenkins-jobs"

jenkins_urlhelp() {
  echo "copy, change and paste for customization"
  echo "export JENKINS_SERVER=${JENKINS_SERVER}"
  echo "export JENKINS_PORT=${JENKINS_PORT}"
  echo "export JENKINS_USER=${JENKINS_USER}"
  echo "export JENKINS_PASS=${JENKINS_PASS}"
  echo "export JENKINS_JOBDIR=${JENKINS_JOBDIR}"
  echo "export JENKINS_URL=\"http://${JENKINS_USER}:${JENKINS_PASS}@${JENKINS_SERVER}:${JENKINS_PORT}\""
}

jenkins_makeurl() {
  echo "http://${JENKINS_USER}:${JENKINS_PASS}@${JENKINS_SERVER}:${JENKINS_PORT}"
}

jenkins_get_clijar() {
  JENKINS_URL=$(jenkins_makeurl)
  echo "Jenkins URL: ${JENKINS_URL}"
  wget ${JENKINS_URL}/jnlpJars/jenkins-cli.jar
}

jenkins_get_plugins() {
  JENKINS_URL=$(jenkins_makeurl)
  java -jar jenkins-cli.jar -s ${JENKINS_URL} groovy = <<<$(echo -e 'import jenkins.model.*\nJenkins.instance.pluginManager.plugins.each{plugin->println("${plugin.getShortName()}:${plugin.getVersion()}")}') | sort
}

jenkins_get_plugins2() {
  JENKINS_URL=$(jenkins_makeurl)
  java -jar jenkins-cli.jar -s ${JENKINS_URL} -webSocket list-plugins | cut -d " " -f1 | sort >  jenkins-plugin-list.txt
}

jenkins_create_user() {
  JENKINS_URL=$(jenkins_makeurl)
  java -jar jenkins-cli.jar -s ${JENKINS_URL} groovy = <<<$(echo -e 'jenkins.model.Jenkins.instance.securityRealm.createAccount("'$1'","'$2'")')
}

jenkins_list_jobs2() {
  JENKINS_URL=$(jenkins_makeurl)
  JENKINS_JOBS=$(java -jar jenkins-cli.jar -s ${JENKINS_URL} -webSocket list-jobs)
  count=1
  while IFS= read -r line
  do
    echo "jobnumber:${count}: ${line}"
    count=$(expr $count + 1)
  done <<<  "${JENKINS_JOBS}"
}

jenkins_list_jobs() {
  JENKINS_URL=$(jenkins_makeurl)
  JENKINS_CRUMB=$(curl -sS --cookie-jar ./_jenkins_crumb_cookie "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
  curl -sS --cookie ./_jenkins_crumb_cookie -H ${JENKINS_CRUMB}  -H "content-type:application/xml"  "${JENKINS_URL}/api/json?pretty=true" | jq -r '.jobs[].name'
  rm -f _jenkins_crumb_cookie
}

jenkins_save_jobs() {
  JENKINS_URL=$(jenkins_makeurl)
  JENKINS_JOBS=$(java -jar jenkins-cli.jar -s ${JENKINS_URL} -webSocket list-jobs)
  count=1
  mkdir -p ${JENKINS_JOBDIR}
  while IFS= read -r jobname
  do
    java -jar jenkins-cli.jar -s ${JENKINS_URL} -webSocket get-job "${jobname}" < /dev/null > "${JENKINS_JOBDIR}/${jobname}.xml"
    count=$(expr $count + 1)
  done <<< "${JENKINS_JOBS}"
}

jenkins_create_jobs() {
  JENKINS_URL=$(jenkins_makeurl)
  JENKINS_JOB_FILES=$(find ${JENKINS_JOBDIR} -maxdepth 1 -type f -name "*.xml" -print)
  echo "${JENKINS_JOB_FILES}"
  while IFS= read -r filename
  do
    jobname=$(basename "${filename%.*}")
    echo "filename: ${filename}, jobname: ${jobname}"
    java -jar jenkins-cli.jar -s ${JENKINS_URL} -webSocket create-job "${jobname}" < "${filename}"
  done <<< "${JENKINS_JOB_FILES}"
}

jenkins_create_credentials() {
  JENKINS_URL=$(jenkins_makeurl)
  JENKINS_CRUMB=$(curl -sS --cookie-jar ./_jenkins_crumb_cookie "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
  cat > _jenkins_creds.xml <<EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>github-access</id>
  <description>Github access credentials</description>
  <username>${1}</username>
  <password>${2}</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
  curl -sS --cookie ./_jenkins_crumb_cookie -H ${JENKINS_CRUMB}  -H "content-type:application/xml"  "${JENKINS_URL}/credentials/store/system/domain/_/createCredentials" -d @_jenkins_creds.xml
  rm -f _jenkins_creds.xml _jenkins_crumb_cookie
}

jenkins_get_job() {
  JENKINS_URL=$(jenkins_makeurl)
  JENKINS_CRUMB=$(curl -sS --cookie-jar ./_jenkins_crumb_cookie "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
  curl -sS --cookie ./_jenkins_crumb_cookie -H ${JENKINS_CRUMB}  -H "content-type:application/xml"  "${JENKINS_URL}/job/${1}/config.xml"
  rm -f _jenkins_crumb_cookie
}

jenkins_internal_run_job() {
  echo "jenkins_run_job: $1"
  JENKINS_URL=$(jenkins_makeurl)
  JENKINS_CRUMB=$(curl -sS --cookie-jar ./_jenkins_crumb_cookie "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
  curl -sS --cookie ./_jenkins_crumb_cookie -H ${JENKINS_CRUMB} "${JENKINS_URL}/job/${1}/build"
  rm -f _jenkins_crumb_cookie
}

jenkins_internal_run_job_params() {
  JENKINS_URL=$(jenkins_makeurl)
  JENKINS_CRUMB=$(curl -sS --cookie-jar ./_jenkins_crumb_cookie "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
  curl -sS -XPOST --cookie ./_jenkins_crumb_cookie -H ${JENKINS_CRUMB} "${JENKINS_URL}/job/${1}/build" --data-urlencode json@"${2}"
  rm -f _jenkins_crumb_cookie
}

jenkins_internal_run_job_usage() {
  PRG_NAME=$(basename $BASH_SOURCE)
  echo "${PRG_NAME} [-h][-n][-j <job>] [-p <params.json>]"
  echo "  -h: print this help information "
  echo "  -n: dry run, print what values will be used"
  echo "  -j: job name to run"
  echo "  -p: parameters for the job to run"
  echo "  -g: generate parameter, run job without parameters"
}

jenkins_run_job() {
  OPTIND=1
  while getopts ":hngj:p:" opt "$@"
  do
    case "${opt}" in
      h ) jenkins_internal_run_job_usage && return 0 ;;
      g ) GEN_PARAMS=1;;
      j ) JOB_NAME="${OPTARG}" ;;
      p ) PARAMS_FILE="${OPTARG}" ;;
      n ) DRY_RUN=1;;
      * ) jenkins_internal_run_job_usage && return 0;;
    esac
  done
  shift $((OPTIND -1))

  [[ ${JOB_NAME} && -z ${GEN_PARAMS} && -z ${PARAMS_FILE} ]] && PARAMS_FILE="${JOB_NAME}-params.json"
  [[ ${JOB_NAME} && -z ${GEN_PARAMS} && ! -f ${PARAMS_FILE} ]] && echo "${PARAMS_FILE} not present" && return 2 

  [[ ${DRY_RUN} ]] && echo "Dry run set: ${DRY_RUN}"
  [[ ${DRY_RUN} ]] && echo && echo "*** --- parameters --- ***"
  [[ ${DRY_RUN} && ${GEN_PARAMS} ]] && echo "Generate parameters set: ${GEN_PARAMS}"
  [[ ${DRY_RUN} && ${JOB_NAME} ]] && echo "Jobname set: ${JOB_NAME}"
  [[ ${DRY_RUN} && ${PARAMS_FILE} ]] && echo "Params file: ${PARAMS_FILE}"
  [[ ${DRY_RUN} ]] && return 1

  # if there no parameter list the jobs
  [[ -z ${JOB_NAME} ]] && jenkins_list_jobs

  # job without parameter
  [[ ${JOB_NAME} && ${GEN_PARAMS} ]] && jenkins_internal_run_job "${JOB_NAME}"

  # job with parameter
  [[ ${JOB_NAME} && -z ${GEN_PARAMS} ]] && jenkins_internal_run_job_params "${JOB_NAME}" "${PARAMS_FILE}"
}
