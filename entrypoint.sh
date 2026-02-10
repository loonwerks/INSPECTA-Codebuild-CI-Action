#!/bin/bash -l

echo "sourcepath: $1"
echo "environment-variables: $2"

rustup toolchain list
rustup target list | grep \(installed\)
rustup component list | grep \(installed\)

sourcePath=system/hamr/microkit
if [[ -n $1 ]]; then
	sourcePath=$1
fi

environmentVariables=""
if [[ -n $2 ]]; then
	environmentVariables=$(echo $2 | jq -r '[to_entries[] | .key + "=" + (.value | tostring)] | join(" ")')
fi

runCommand=(${environmentVariables} RUST_MAKE_TARGET=build-release make -C $GITHUB_WORKSPACE/${sourcePath})

outputFile="codegen.out"
if [[ -n $3 ]]; then
	outputFile=$3
fi

echo "run command: ${runCommand[@]}" 

"${runCommand[@]}" >> "$outputFile"
EXIT_CODE=$?

echo "timestamp=$(date)" >> $GITHUB_OUTPUT
echo "status=${EXIT_CODE}" >> $GITHUB_OUTPUT
echo "status-messages=$(cat ${outputFile} | jq -R -s '.')" >> $GITHUB_OUTPUT

echo "exit code: $EXIT_CODE"
if [ "XX $EXIT_CODE" = "XX 0" ]; then
	exit 0
else
	exit 1
fi
