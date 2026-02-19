#!/bin/bash -l

echo "sourcepath: $1"
echo "environment-variables: $2"
echo "report-filename: $3"

rustup toolchain list
rustup target list | grep \(installed\)
rustup component list | grep \(installed\)

sourcePath=system/hamr/microkit
if [[ -n $1 ]]; then
	sourcePath=$1
fi

if [[ -n $2 ]]; then
	for kv in $(echo $2 | jq -r 'to_entries | .[] | .key + "=" + (.value | @sh)'); do
		echo "setting ${kv}"
		export $kv;
	done
fi

runCommand=(make -C $GITHUB_WORKSPACE/${sourcePath})

reportFilename=$(mktemp)
if [[ -n $3 ]]; then
	reportFilename=$3
fi

startTimestamp=$(date)

export RUST_MAKE_TARGET=build-release
echo "run command: ${runCommand[@]}" 

outputFile=$(mktemp)
"${runCommand[@]}" >> "$outputFile" 2>&1
EXIT_CODE=$?
cat $outputFile

clocReport=$(mktemp)
cloc --exclude-lang=YAML --json --report-file=${clocReport} ${GITHUB_WORKSPACE}

codebuildMessages=$(mktemp)
cat ${outputFile} | jq --raw-input . | jq --slurp '{"messages" : .}' > ${codebuildMessages}

clocReportSub=$(mktemp)
jq '{"cloc" : .}' ${clocReport} > ${clocReportSub}

jq -s 'add' ${codebuildMessages} ${clocReportSub} \
    | jq --arg timestamp "${startTimestamp}" --arg exitcode ${EXIT_CODE} '. += $ARGS.named' \
    > ${reportFilename}
chmod +r ${reportFilename}

echo "timestamp=${startTimestamp}" >> $GITHUB_OUTPUT
echo "status=${EXIT_CODE}" >> $GITHUB_OUTPUT

echo "exit code: $EXIT_CODE"
if [ "XX $EXIT_CODE" = "XX 0" ]; then
	exit 0
else
	exit 1
fi
