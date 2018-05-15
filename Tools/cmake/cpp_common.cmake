# This code relies on the following cmake variables:
#       - is_debug
#       - is_release_noopt

if(MSVC)
    add_definitions(-DUNICODE -D_UNICODE)                                       # Use UNICODE character set
            
    add_compile_options(                                                        # Option
                                                                                # ------------------------------------
        /bigobj                                                                 # Increase number of sections in object file
        /GR+                                                                    # Run Time Type Information (RTTI)
        /MP                                                                     # Build with multiple processes
        /openmp                                                                 # OpenMP 2.0 Support
        /sdl                                                                    # Enable Additional Security Checks
        /W4                                                                     # Warning level 4
        /WX                                                                     # Warning as errors
    )           
                                                                                # Option                                Debug                   Release                 Release_NoOpt
                                                                                # ------------------------------------  ----------------------  ----------------------  ----------------------
    add_compile_options($<IF:${is_debug},/ZI,/Zi>)                              # Program Database                      Edit & Continue         Standard                Standard
    add_compile_options($<IF:${is_debug},/fp:fast,/fp:except->)                 # Floating point model/exceptions       fast                    None                    None
    add_compile_options($<$<NOT:$<OR:${is_debug},${is_release_noopt}>>:/Ot>)    # Favor Size or Speed                   Neither                 fast                    Neither
    
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /PROFILE")            # Enable profiling
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /PROFILE")      # Enable profiling
    
else()
    add_compile_options(-W -Wall -Werror)
endif()

set(CMAKE_CXX_FLAGS_RELEASE_NOOPT ${CMAKE_CXX_FLAGS_RELEASE})
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE_NOOPT ${CMAKE_SHARED_LINKER_FLAGS_RELEASE})
