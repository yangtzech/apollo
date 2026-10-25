#!/usr/bin/env bash
# Personal Apollo 11 AEM full-source build and clangd profile.
set -euo pipefail

workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$workspace"

if [[ $# != 1 ]]; then
    printf 'Usage: bash scripts/local_dev.sh {prepare|build|compile_commands}\n' >&2
    exit 2
fi

case "$1" in
    prepare)
        # buildtool generates this assignment for a single-package workspace.
        # A full-source checkout must keep all local proto labels local.
        sed -i 's/^package_path = "[^"]*"$/package_path = "@@REPLACE@@"/' tools/proto/proto.bzl
        if [[ ! -f tools/external/openssl.BUILD && -f third_party/openssl/openssl.BUILD ]]; then
            sed -i 's#build_file = "tools/external/openssl.BUILD"#build_file = "third_party/openssl/openssl.BUILD"#g' WORKSPACE
        fi
        exit 0
        ;;
    build|compile_commands) ;;
    *)
        printf 'Unknown action: %s\n' "$1" >&2
        exit 2
        ;;
esac

if [[ ! -f /.dockerenv ]]; then
    printf 'Run this profile inside the AEM development container.\n' >&2
    exit 2
fi
if ! grep -q '^package_path = "@@REPLACE@@"$' tools/proto/proto.bzl; then
    printf 'Run bash scripts/local_dev.sh prepare after AEM dependency preparation.\n' >&2
    exit 2
fi

link_flags=()
for lib_dir in /usr/local/lib /usr/lib /opt/apollo/neo/lib/* /opt/apollo/neo/packages/*/latest/lib /opt/apollo/pkgs/*/lib; do
    if [[ -d "$lib_dir" ]]; then
        link_flags+=("--linkopt=-L$lib_dir" "--host_linkopt=-L$lib_dir")
    fi
done
compile_flags=(
    --config=gpu -c opt
    --copt=-mavx2 --host_copt=-mavx2
    "--action_env=TF_CUDA_COMPUTE_CAPABILITIES=${APOLLO_LOCAL_CUDA_ARCH:-8.6}"
    "${link_flags[@]}"
)
resource_flags=(
    "--jobs=${APOLLO_LOCAL_JOBS:-6}"
    '--local_ram_resources=HOST_RAM*0.5'
)

# Use the output root from .apollo.bazelrc for both Bazel and Hedron's nested queries.
case "$1" in
    build)
        exec bazel build --keep_going "${resource_flags[@]}" "${compile_flags[@]}" -- \
            //cyber/... //modules/... \
            -//modules/perception/common/inference/migraphx/...
        ;;
    compile_commands)
        exec bazel run "${resource_flags[@]}" "${compile_flags[@]}" \
            //:refresh_compile_commands -- "${compile_flags[@]}"
        ;;
esac
