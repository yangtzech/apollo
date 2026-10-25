load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])

cc_library(
    name = "client_sdk",
    srcs = glob([
        "src/sdk_client/**/*.cpp",
        "src/sdk_common/**/*.cpp",
        "src/utils/*.cpp",
    ]),
    hdrs = glob(["src/**/*.h"]),
    textual_hdrs = ["src/sdk_common/version_gen.gen_cc"],
    includes = ["src"],
    strip_include_prefix = "src",
    include_prefix = "seyond",
    # Match the vendor's Linux packing and warning settings.
    copts = ["-mno-ms-bitfields", "-w"] + select({
        "@platforms//cpu:x86_64": ["-DHAVE_SSE42", "-msse4.2"],
        "//conditions:default": [],
    }),
    linkopts = ["-pthread", "-lrt"],
    visibility = ["//visibility:public"],
)
