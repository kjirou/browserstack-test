#!/bin/sh

#
# CircleCI 上で E2E テストを実行する
#
# Ref) https://circleci.com/docs/nightly-builds
#

_usage="usage: $0 [-b branch_name] [-t circle_token]"
_branch=''
_circle_token=''

while getopts 'b:t:' flag; do
  case $flag in
    b)
      _branch="$OPTARG";
      ;;
    t)
      _circle_token="$OPTARG";
      ;;
    \?)
      option_error=1;
      break
      ;;
  esac
done
shift `expr $OPTIND - 1`
if [ $option_error ]; then
  echo >&2 'Invalid option(s)'
  echo >&2 $_usage
  exit 1
fi

if [ "$_branch" = '' ]; then
  _branch='master'
fi
if [ "$_circle_token" = '' ]; then
  # Created from https://circleci.com/gh/plaidev/karte-io/edit#api
  _circle_token='d14416eadd082e566659f7ae504c5f645ba90ad0'
fi

trigger_build_url=https://circleci.com/api/v1/project/plaidev/karte-io/tree/${_branch}?circle-token=${_circle_token}
echo $trigger_build_url

post_data=$(cat <<EOF
{
  "build_parameters": {
    "SHOULD_NOT_RUN_DEFAULT_TEST": "true",
    "SHOULD_RUN_E2E_TEST": "true"
  }
}
EOF)

curl \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data "${post_data}" \
--request POST ${trigger_build_url}
