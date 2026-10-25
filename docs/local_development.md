# Personal Apollo 11 development profile

This fork keeps local build fixes and a clangd workflow on top of upstream
`master`. The profile was validated with Ubuntu 22.04 in AEM, CUDA 11.8,
Bazel 5.3.2, GCC 11, and an NVIDIA RTX 3060.

## Build and generate the compilation database

Start or enter a GPU AEM environment with the Apollo dependencies installed,
then run these commands from the full-source checkout inside the container:

```bash
bash scripts/local_dev.sh prepare
bash scripts/local_dev.sh build
bash scripts/local_dev.sh compile_commands
```

`prepare` repairs two generated values left by older buildtool versions: the
single-package proto mode and the removed OpenSSL build-file path. Run it again
after dependency preparation rewrites those files. It does not install SDKs or
delete build outputs. This workflow assumes dependency installation succeeded;
installation/download failures still need to be resolved before building.

The build covers `//cyber/...` and `//modules/...`, excluding the AMD-only
MIGraphX backend for the NVIDIA profile. Existing frontend `dist` files are used;
JavaScript sources are not independently bundled. Test binaries are built, but
the script does not execute unit tests.

The profile defaults to six jobs, half host RAM, AVX2, and CUDA capability 8.6.
Override `APOLLO_LOCAL_JOBS` or `APOLLO_LOCAL_CUDA_ARCH` when appropriate for your
machine. Keep the `.apollo.bazelrc` output root on reliable local storage.

The generated `compile_commands.json` includes project sources and project
headers; external sources/headers are omitted to reduce its size. The database
uses container paths such as `/apollo_workspace` and `/opt/apollo`, and is
intended for clangd running inside that same container, for example through a
remote-container editor. Host-side clangd needs a separate path/sysroot mapping.

## Local state and commits

AEM regenerates the section between the two Apollo markers in `WORKSPACE`, and
also rewrites `tools/package/dynamic_deps.bzl`. Keep this machine-specific state
out of commits. The checked-in workspace contains the upstream template plus
the pinned personal dependencies outside those markers.
`WORKSPACE.source` retains the same pinned repositories so source-workspace
restoration does not discard the editor and SDK dependencies.

Commit only reviewed paths. Do not commit model weights, build caches/logs,
`.env`, `.aem`, or `compile_commands.json`. The original manual `parser.py` is
not required by this workflow.

## Upstream updates

The intended remotes are `origin` for your fork and `upstream` for
`ApolloAuto/apollo`. Keep personal changes as focused commits on your fork's
`master`. Before merging upstream updates, preserve generated working-tree
state locally and review any changes to the build configuration.

## Validation

The full NVIDIA build analyzed 15,020 targets and passed. A bounded Cyber RT
talker/listener check received seven messages. The Seyond driver uses a pinned
official SDK source revision so its headers and implementation match. The RSS
test has a separate dependency on its original 1.1.0 test-support headers.
Seyond hardware and the full unit-test suite have not been exercised.
