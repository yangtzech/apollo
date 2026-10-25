# Seyond client SDK

The Seyond lidar driver uses the official `release-3.103.13` SDK, pinned to
commit `73a24e98c283391b890cfd106e5cc13e9c9d7f5b` and an archive SHA256 in
`WORKSPACE`.

Upstream: https://github.com/Seyond-Inc/inno-lidar-sdk/tree/73a24e98c283391b890cfd106e5cc13e9c9d7f5b

The older AEM `seyond-driver` package provides SDK 3.100.0 and does not declare
`kInnoAngleHVTableMaxSize`, which Apollo's current driver requires. The Bazel
target builds matching SDK headers and implementation together, using Apollo's
C++ standard and ABI. Public headers retain the `seyond/` include prefix.

The SDK is built from its client, common, and utility sources. Its Linux packing,
warning, and x86 SSE settings follow the vendor's CMake configuration. The
upstream archive retains its BSD 2-Clause license and source notices.

This integration has passed compilation. Real lidar hardware has not been tested.
