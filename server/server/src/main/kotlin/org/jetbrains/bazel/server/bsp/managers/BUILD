load("//rules/kotlin:macros.bzl", "kt_library")

kt_library(
    name = "managers",
    srcs = glob([
        "*.kt",
    ]),
    visibility = ["//server/server:__subpackages__"],
    deps = [
        "//commons/src/main/kotlin/org/jetbrains/bazel/commons/gson",
        "//commons/src/main/kotlin/org/jetbrains/bazel/workspacecontext",
        "//server/bazelrunner",
        "//server/commons",
        "//server/server/src/main/kotlin/org/jetbrains/bazel/server/bep",
        "//server/server/src/main/kotlin/org/jetbrains/bazel/server/bsp/utils",
        "//server/server/src/main/kotlin/org/jetbrains/bazel/server/bsp/utils:fileutils",
        "//server/server/src/main/kotlin/org/jetbrains/bazel/server/bsp/utils:structured_files_utils",
        "//server/server/src/main/kotlin/org/jetbrains/bazel/server/bzlmod",
        "//server/server/src/main/kotlin/org/jetbrains/bazel/server/diagnostics",
        "//server/server/src/main/kotlin/org/jetbrains/bazel/server/label",
        "@maven//:com_google_guava_guava",
        "@maven//:io_grpc_grpc_protobuf",
        "@maven//:org_apache_velocity_velocity_engine_core",
        "@maven//:org_slf4j_slf4j_api",
    ],
)
