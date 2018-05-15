# Functionality to aid in the debugging of cmake and the cmake generation process.

if(CMAKE_DEBUG)
    get_cmake_property(_variables VARIABLES)
    list (SORT _variables)
    foreach (_var ${_variables})
        message(STATUS "${_var}=${${_var}}")
    endforeach()
endif()