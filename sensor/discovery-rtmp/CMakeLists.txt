set(service "smtc_rtmp_discovery")
include("${CMAKE_SOURCE_DIR}/script/service.cmake")
add_dependencies(build_${service} build_smtc_common)
