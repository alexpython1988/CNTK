# This file contains definitions for C++ settings that impact the Application Binary Interface (ABI) and should
# be generally applicable across a variety of different projects. Project-specific customizations should be defined
# in a separate file.

set(CMAKE_CONFIGURATION_TYPES Debug;Release;Release_NoOpt)

set(is_debug $<CONFIG:Debug>)
set(is_release_noopt $<CONFIG:Release_NoOpt>)

if(MSVC)
    add_definitions(-DUNICODE -D_UNICODE)                                                       # Use UNICODE character set
                            
    add_compile_options(                                                                        # Option
                                                                                                # ------------------------------------
        /bigobj                                                                                 # Increase number of sections in object file
        /fp:except-                                                                             # Enable Floating Point Exceptions: No
        /fp:fast                                                                                # Floating Point Model: Fast
        /GR+                                                                                    # Run Time Type Information (RTTI)
        /MP                                                                                     # Build with multiple processes
        /openmp                                                                                 # OpenMP 2.0 Support
        /sdl                                                                                    # Enable Additional Security Checks
        /W4                                                                                     # Warning level 4
        /WX                                                                                     # Warning as errors
    )                           
                                                                                                # Option                                Debug                   Release                 Release_NoOpt
                                                                                                # ------------------------------------  ----------------------  ----------------------  ----------------------
    add_compile_options($<$<NOT:${is_debug}>:/Gy>)                                              # Enable Function-Level Linking         <Default>               Yes                     Yes
    add_compile_options($<$<NOT:${is_debug}>:/Oi>)                                              # Enable Intrinsic Functions            <Default>               Yes                     Yes
    add_compile_options($<$<NOT:$<OR:${is_debug},${is_release_noopt}>>:/Ot>)                    # Favor Size or Speed                   <Default>               fast                    <Default>
    add_compile_options($<$<NOT:${is_debug}>:/Qpar>)                                            # Enable Parallel Code Generation       <Default>               Yes                     Yes
    add_compile_options($<IF:${is_debug},/ZI,/Zi>)                                              # Program Database                      Edit & Continue         Standard                Standard
    
    # Set linker flags. Note that there isn't a cmake method called add_linker_options
    # that is able to handle generator expressions, so we have to do the generation manually.
    foreach(linker_flag
                                                                                                # Option
                                                                                                # ------------------------------------
        /PROFILE;                                                                               # Enable profiling
    )
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${linker_flag}")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${linker_flag}")
    endforeach()
    
    # Release-specific linker flags
    foreach(linker_flag 
                                                                                                # Option
                                                                                                # ------------------------------------
        /DEBUG;                                                                                 # Generate Debug Information
        /OPT:ICF;                                                                               # Enable COMDAT Folding
        /OPT:REF;                                                                               # References
    )
        set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} ${linker_flag}")
        set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} ${linker_flag}")
    endforeach()

else()
    add_compile_options(-W -Wall -Werror)
endif()

# Define the Release_NoOpt configuration in terms of Release. Differentiation between the configurations 
# are handled in add_compile_options above.
set(CMAKE_CXX_FLAGS_RELEASE_NOOPT ${CMAKE_CXX_FLAGS_RELEASE})
set(CMAKE_EXE_LINKER_FLAGS_RELEASE_NOOPT ${CMAKE_EXE_LINKER_FLAGS_RELEASE})
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE_NOOPT ${CMAKE_SHARED_LINKER_FLAGS_RELEASE})
