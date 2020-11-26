#! /usr/bin/env bash

function get_references() {
	echo $1
	REFERENCES=$(dotnet list $1 reference)
	COUNT=$(echo "$REFERENCES" | wc -l)
	if (($COUNT > 1)); then
		REFERENCES=$(echo "$REFERENCES" | sed 1,2d | sed 's/\\/\//g') 
		echo "$REFERENCES" | while read line ; do get_references $(realpath "$(dirname $1)/$line") ; done 
	fi
}

# TODO: Replace with upsearch function or make script executable from sln root
ROOT_DIR=$(git rev-parse --show-toplevel)
echo "Root dir: $ROOT_DIR"

echo "Searching for references..."
all_references=$(get_references "$(pwd)/$(find *.csproj)" | xargs -n1 realpath --relative-to $ROOT_DIR | tac)

echo "$all_references"

printf "\n\nGenerating Dockerfile...\n--------------------------------\n"

project_file=$(echo "$all_references" | tail -n 1)
project_filename=$(basename $project_file)

cat > ./.dockerignore <<-EOF
**/.classpath
**/.dockerignore
**/.env
**/.git
**/.gitignore
**/.project
**/.settings
**/.toolstarget
**/.vs
**/.vscode
**/*.*proj.user
**/*.dbmdl
**/*.jfm
**/azds.yaml
**/bin
**/charts
**/docker-compose*
**/Dockerfile*
**/node_modules
**/npm-debug.log
**/obj
**/secrets.dev.yaml
**/values.dev.yaml
README.md
EOF

cat > ./Dockerfile <<-EOF
# This dockerfile is generated
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src

$(echo "$all_references" | while read line ; do echo "COPY [\"$line\", \"$(dirname $line)\"]" ; done )

RUN dotnet restore "$project_file"

$(echo "$all_references" | while read line ; do echo "COPY [\"$(dirname $line)\", \"$(dirname $line)\"]" ; done )

WORKDIR "/src/$(dirname $project_file)"
RUN dotnet build "$project_filename)" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "$project_filename" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "$(basename $project_file .csproj).dll"]
EOF

cat ./Dockerfile
printf "\n--------------------------------\nWritten to: $(realpath ./Dockerfile)\n"
exit 0
