# ApolloGraphQL Code Generator

This command-line tool can be used to:
- Download a GraphQL schema from a server
- Generate code based on the GraphQL schema and any user-provided queries and/or mutations

This follows the instructions provided in [the Apollo documentation on Swift Scripting](https://www.apollographql.com/docs/ios/swift-scripting/).

## Installation

The easiest way to install and run the tool is [using Mint](https://github.com/yonaskolb/Mint). Mint can be installed via [Homebrew](https://brew.sh).

Installing and running via Mint is as simple as running:

```
mint run RocketLaunchpad/ApolloGraphQL-Codegen@main ...
```

followed by the appropriate sub-commands and arguments, discussed below.

**NOTE: The command references the `main` branch. Once a release of this repo has been tagged, the command should be updated to reference that tag.**

## Downloading a Schema

To download a schema, run the following sub-command:

```
mint run RocketLaunchpad/ApolloGraphQL-Codegen@main download-schema
```

This sub-command supports the following arguments:

| Argument               | Description                                                                                              |
|:-----------------------|:---------------------------------------------------------------------------------------------------------|
| `-d` or `--debug`      | Print debug output.                                                                                      |
| `-e` or `--endpoint`   | The endpoint URL from which the schema is to be downloaded.                                              |
| `-o` or `--output-dir` | The directory to which the schema is to be written.                                                      |
| `-h` or `--help`       | Show help information.                                                                                   |

### Schema Download Example

This command downloads a schema from the specified URL and writes it to the specified output directory:

```
mint run RocketLaunchpad/ApolloGraphQL-Codegen@main download-schema \
    --endpoint "https://your.domain.name/path/to/graphql/endpoint" \
    --output-dir "Sources/GraphQL/Schema"
```

## Generating Code

To generate code, run the following sub-command:

```
mint run RocketLaunchpad/ApollographQL-Codegen@main generate-code
```

This sub-command supports the following arguments:

| Argument                | Description                                                                                              |
|:------------------------|:---------------------------------------------------------------------------------------------------------|
| `-c` or `--cli-dir`     | The Apollo CLI directory. If the CLI has not yet been downloaded, it will be downloaded and stored here. |
| `-d` or `--debug`       | Print debug output.                                                                                      |
| `-f` or `--force`       | Force the build to occur, ignoring the modification times of input and output files.                     |
| `-o` or `--output-file` | Generated code output filename.                                                                          |
| `-s` or `--schema-file` | The schema filename. Generally this is downloaded by `download-schema` described above.                  |
| `-h` or `--help`        | Show help information.                                                                                   |
| `<includes>`            | A glob pattern specifying user-provided GraphQL queries and mutations to be included.                    |

### CLI Directory

Note that the Apollo CLI is fairly large (at the time of this writing, it was 171 MB). You should pick a location for it and reference that same location every time you use this tool. This will prevent downloading and unpacking the CLI more than is absolutely necessary.

### Build Optimization

The tool compares the modification dates of the input files (the `--schema-file` argument and the files matching the `<includes>` glob) against the modification date of the output file (the `--output-file` argument). If the output file was modified after all of the input files, the build will not be performed. This behavior can be overridden by the `--force` flag.

This is done to optimize build times, both from this tool, and in the ensuing build in Xcode. If the generated code file is not modified, Xcode will not recompile it. If it is rewritten (even without changes), Xcode will recompile it and any files that reference it.

### Code Generation Example

This command compiles the specified schema, including all of the `.graphql` files (for your queries and mutations) under the `Sources/GraphQL/Source` directory:

```
mint run RocketLaunchpad/ApolloGraphQL-Codegen@main generate-code \
    --cli-dir "$HOME/ApolloCLI" \
    --output-file "Sources/Generated/GeneratedCode.swift" \
    --schema-file "Sources/GraphQL/Schema/schema.graphqls" \
    Sources/GraphQL/Source/**/*.graphql
```

## Tips

Invoking the tool will involve commands like those listed in the examples above. It is best to write a shell script containing these commands and put them in the `bin` directory inside your project. For example, you would write two scripts: `bin/download-schema.sh` and `bin/generate-code.sh`. You can then invoke the scripts from the terminal, or from Xcode.

Updating the schema *should not* occur on every build. Rather, it should only be done when there are schema changes need to be integrated. As such, running your `download-schema` script should be done either in the terminal or as an Aggregate Target in Xcode.

Generating code *should* be done as part of every build, especially since the tool is optimized to skip the code generation if the inputs have not changed since the last build. As such, running the `generate-code` script should be done as a build phase script in Xcode that is performed before the main "Compile Swift Sources" step.

## Integration Example

If using Mint is not feasible on your project, you can set things up to use Git and SPM to update and run this package.

At the root of your project, include a `bin` directory to place scripts.

This assumes at the root of your peojct, you have the following directories:

```
PROJECT_ROOT/
  GraphQL/
    Generated/
      (your generated API will go here)
    Schema/
      (the downloaded schema will go here)
    Source/
      (your queries and mutations in graphql files)
```

You can configure the scripts to use a different layout by editing the variables in the scripts described below.

### `bin/codegen.sh`

Create `bin/codgen.sh`. This clones this repo to `bin/codegen` and builds it using `xcrun --sdk macos swift build`. Note the use of the `codegen_version` variable: this is the branch or tag of this repo that you want to use. If you want to update to a later version, simply update this variable to reference the desired version.

While the script calls `git checkout` and `xcrun --sdk macos swift build` each time it is invoked, this should complete quickly if there are no changes to the branch/tag being referenced.

```bash
#!/usr/bin/env bash

set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
codegen_dir="$script_dir/codegen"
codegen_url="https://github.com/RocketLaunchpad/ApolloGraphQL-Codegen"
codegen_version="0.51.1"

codegen_executable="$codegen_dir/.build/debug/codegen"

if [ ! -d "$codegen_dir" ]; then
    git clone "$codegen_url" "$codegen_dir"
fi

pushd "$codegen_dir"
git fetch
git checkout "$codegen_version"
xcrun --sdk macosx swift build
popd

"$codegen_executable" $@
```

### `bin/.gitignore`

Create or update `bin/.gitignore` to include the `bin/codegen` directory:

```
codegen/
```

### `bin/download-schema.sh`

This file will vary depending on the project. At the very least, you will need something like the following:

```bash
#!/usr/bin/env bash

set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_root="$( cd "$script_dir" && cd .. && pwd )"

## This is where the schema will be downloaded. This path will also be used in bin/generate-code.sh.
schema_dir="$project_root/GraphQL/Schema"

## NOTE: This URL needs to be set to your schema source URL
schema_source_url="..."

"$script_dir/codegen.sh" \
    download-schema \
    --endpoint="$schema_source_url" \
    --output-dir="$schema_dir"
```

### `bin/generate-code.sh`

This file can also vary depending on the project. Note the use of the `cli_dir` variable. Here, we store the Apollo CLI under `$HOME/Library/ApolloGraphQL-Codegen`. You may prefer to keep it somewhere else, possibly containing the project name in the path, allowing for different projects on the same machine to use different versions of the framework.

```bash
#!/usr/bin/env bash

set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_root="$( cd "$script_dir" && cd .. && pwd )"

## CONFIGURATION -------------------------------------------

## This is where Apollo keeps its CLI used for compilation. You can adjust this as necessary (see README comment).
cli_dir="$HOME/Library/ApolloGraphQL-Codegen"

## INPUTS --------------------------------------------------

## The schema being compiled. The input schema is the file downloaded by bin/download-schema.sh.
input_schema="$project_root/GraphQL/Schema/schema.graphqls"

## This recursive glob pattern should match all of the graphql source files being compiled.
glob="$project_root/GraphQL/Source/**/*.graphql"

## OUTPUTS -------------------------------------------------

## This is the generated API file.
output_generated_api="$project_root/GraphQL/Generated/GeneratedAPI.swift"

"$script_dir/codegen.sh" \
    generate-code \
    --debug \
    --cli-dir "$cli_dir" \
    --output-file "$generated_api" \
    --schema-file "" \
    "$glob"
```

### Xcode Build Phase: Compile Schema

Add a build phase to your target _before the Compile Sources build phase_. Call the build phase _Compile Schema_. It should invoke the `generate-code.sh` script above:

```
"$PROJECT_DIR/bin/generate-code.sh"
```

### Xcode project membership

Only add the generated API Swift file (i.e., the path in the `output_generated_api` variable in `bin/generate-code.sh`) to any of your Xcode targets. You don't need (and likely don't want) to add the schema or graphql queries and mutations to any targets.

You can add the entire `GraphQL` directory structure to Xcode for easier source editing and schema viewing. Just make sure none of the files have any target membership checked.

