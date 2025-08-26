# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appinterface_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appinterface_autogen.dir\\ParseCache.txt"
  "appinterface_autogen"
  )
endif()
