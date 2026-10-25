load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])

cc_library(
    name = "test_support",
    testonly = True,
    hdrs = [
        "src/physics/Math.hpp",
        "tests/test_support/RSSParameters.hpp",
        "tests/test_support/TestSupport.hpp",
    ],
    includes = ["src", "tests/test_support"],
    deps = [
        "@ad_rss_lib//:ad_rss",
        "@com_google_googletest//:gtest",
    ],
    visibility = ["//visibility:public"],
)
