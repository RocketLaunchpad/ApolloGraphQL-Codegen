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
| `-c` or `--cli-dir`    | The Apollo CLI directory. If the CLI has not yet been downloaded, it will be downloaded and stored here. |
| `-d` or `--debug`      | Print debug output.                                                                                      |
| `-e` or `--endpoint`   | The endpoint URL from which the schema is to be downloaded.                                              |
| `-f` or `--format`     | The output format (`json` or `sdl`).                                                                     |
| `-o` or `--output-dir` | The directory to which the schema is to be written.                                                      |
| `-h` or `--help`       | Show help information.                                                                                   |

[See the note below about the Apollo CLI directory.](#cli-directory)

### Schema Download Example

This command downloads a schema from the specified URL and writes it to the specified output directory in JSON as well as the Schema Definition Language.

```
mint run RocketLaunchpad/ApolloGraphQL-Codegen@main download-schema \
    --cli-dir "$HOME/ApolloCLI" \
    --endpoint "https://your.domain.name/path/to/graphql/endpoint" \
    --format json \
    --format sdl \
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

[See the note below about the Apollo CLI directory.](#cli-directory)

### Build Optimization

That the tool compares the modification dates of the input files (the `--schema-file` argument and the files matching the `<includes>` glob) against the modification date of the output file (the `--output-file` argument). If the output file was modified after all of the input files, the build will not be performed. This behavior can be overridden by the `--force` flag.

This is done to optimize build times, both from this tool, and in the ensuing build in Xcode. If the generated code file is not modified, Xcode will not recompile it. If it is rewritten (even without changes), Xcode will recompile it and any files that reference it.

### Code Generation Example

This command compiles the specified schema, including all of the `.graphql` files (for your queries and mutations) under the `Sources/GraphQL/Source` directory:

```
mint run RocketLaunchpad/ApolloGraphQL-Codegen@main generate-code \
    --cli-dir "$HOME/ApolloCLI" \
    --output-file "Sources/Generated/GeneratedCode.swift" \
    --schema-file "Sources/GraphQL/Schema/schema.graphql" \
    Sources/GraphQL/Source/**/*.graphql
```

## CLI Directory

Note that the Apollo CLI is fairly large (at the time of this writing, it was 159 MB). You should pick a location for it and reference that same location every time you use this tool. This will prevent downloading and unpacking the CLI more than is absolutely necessary.

## Tips

Invoking the tool will involve commands like those listed in the examples above. It is best to write a shell script containing these commands and put them in the `bin` directory inside your project. For example, you would write two scripts: `bin/download-schema.sh` and `bin/generate-code.sh`. You can then invoke the scripts from the terminal, or from Xcode.

Updating the schema should not occur on every build. Rather, it should only be done when there are schema changes need to be integrated. As such, running your `download-schema` script should be done either in the terminal or as an Aggregate Target in Xcode.

Generating code should be done as part of every build, especially since the tool is optimized to skip the code generation if the inputs have not changed since the last build. As such, running the `generate-code` script should be done as a build phase script in Xcode that is performed before the main "Compile Swift Sources" step.

