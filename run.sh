#!/usr/bin/env bash
# Convenience runner for the Day 3 lab.   ./run.sh <mode>
# Every mode is a plain robot command, shown in the README as well.
cd "$(dirname "$0")" || exit 1
PY="${PYTHON:-python3}"
R="$PY -m robot -A lab.args"
case "${1:-help}" in
  check)    $PY check_setup.py ;;
  first)    $R --outputdir results/first suites/attach.robot ;;
  scopes)   $R --outputdir results/scopes suites/variables_demo.robot ;;
  override) $R --variable ENB_HOST:10.9.9.9 --outputdir results/override suites/variables_demo.robot ;;
  smoke)    $R --include smoke --outputdir results/smoke suites ;;
  full)     $R --exclude long --outputdir results/full suites ;;
  fault)    LAB_FAULT=no_ip $R --include attach --outputdir results/fault suites/attach.robot ;;
  fail)     $R --outputdir results/failing demos/failing_demo.robot ;;
  api)      $R --outputdir results/api suites/libraries/provision_api.robot ;;
  libs)     $R --outputdir results/libs suites/libraries/standard_libs.robot ;;
  library)  $R --outputdir results/library suites/keyword_library.robot ;;
  mine)     $R --outputdir results/mine exercises/my_library_test.robot ;;
  dryrun)   $R --dryrun --outputdir results/dryrun suites demos ;;
  *) echo "Usage: ./run.sh check|first|scopes|override|smoke|full|fault|fail|api|libs|library|mine|dryrun"; exit 1 ;;
esac
