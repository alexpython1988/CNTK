cmake_minimum_required (VERSION 3.8)

include(../../../Tools/cmake/common.cmake REQUIRED)

EnsureProperties(CNTK_VERSION;)
EnsureTools(swig;)

include(../../../Tools/cmake/cpp_common.cmake REQUIRED)

set(binary_name_suffix -${CNTK_VERSION}$<${is_debug}:d>)
set(binary_name Cntk.Core.CSBinding${binary_name_suffix})

# ----------------------------------------------------------------------
# |  SWIG

# swig generates the same C++ files for all configurations. However, it is configured to generate 
# different files for C# as some of those generated files will pinvoke to specific CNTK dlls, which 
# are built with filenames that are different between debug and release (the debug variation has 
# a 'd' suffix).
set(swig_config $<IF:${is_debug},Debug,Release>)

set(native_swig_generated_files
        Generated/cntk_cs_wrap.h
        Generated/cntk_cs_wrap.cxx
)

set(csharp_swig_generated_files
        ;
        
        # cmake doesn't like lists that resolve to generator expresions used as outputs
        # Generated/${swig_config}/AdditionalLearningOptions.cs;
        # Generated/${swig_config}/Axis.cs;
        # Generated/${swig_config}/AxisVector.cs;
        # Generated/${swig_config}/BoolVector.cs;
        # Generated/${swig_config}/CharVector.cs;
        # Generated/${swig_config}/CNTKDictionary.cs;
        # Generated/${swig_config}/CNTKLib.cs;
        # Generated/${swig_config}/CNTKLibPINVOKE.cs;
        # Generated/${swig_config}/Constant.cs;
        # Generated/${swig_config}/ConstantVector.cs;
        # Generated/${swig_config}/DataType.cs;
        # Generated/${swig_config}/DataUnit.cs;
        # Generated/${swig_config}/DeviceDescriptor.cs;
        # Generated/${swig_config}/DeviceDescriptorVector.cs;
        # Generated/${swig_config}/DeviceKind.cs;
        # Generated/${swig_config}/DictionaryValue.cs;
        # Generated/${swig_config}/DictionaryVector.cs;
        # Generated/${swig_config}/DoubleVector.cs;
        # Generated/${swig_config}/DoubleVectorVector.cs;
        # Generated/${swig_config}/Evaluator.cs;
        # Generated/${swig_config}/float16.cs;
        # Generated/${swig_config}/FloatVector.cs;
        # Generated/${swig_config}/FloatVectorVector.cs;
        # Generated/${swig_config}/Function.cs;
        # Generated/${swig_config}/FunctionPtrVector.cs;
        # Generated/${swig_config}/HTKFeatureConfiguration.cs;
        # Generated/${swig_config}/HTKFeatureConfigurationVector.cs;
        # Generated/${swig_config}/IntVector.cs;
        # Generated/${swig_config}/Learner.cs;
        # Generated/${swig_config}/LearnerVector.cs;
        # Generated/${swig_config}/MaskKind.cs;
        # Generated/${swig_config}/MinibatchData.cs;
        # Generated/${swig_config}/MinibatchInfo.cs;
        # Generated/${swig_config}/MinibatchSource.cs;
        # Generated/${swig_config}/MinibatchSourceConfig.cs;
        # Generated/${swig_config}/ModelFormat.cs;
        # Generated/${swig_config}/NDArrayView.cs;
        # Generated/${swig_config}/NDArrayViewPtrVector.cs;
        # Generated/${swig_config}/NDMask.cs;
        # Generated/${swig_config}/NDShape.cs;
        # Generated/${swig_config}/PaddingMode.cs;
        # Generated/${swig_config}/PairDoubleDouble.cs;
        # Generated/${swig_config}/PairFloatFloat.cs;
        # Generated/${swig_config}/PairIntInt.cs;
        # Generated/${swig_config}/PairNDArrayViewPtrNDArrayViewPtr.cs;
        # Generated/${swig_config}/PairSizeTDouble.cs;
        # Generated/${swig_config}/PairSizeTInt.cs;
        # Generated/${swig_config}/PairSizeTSizeT.cs;
        # Generated/${swig_config}/Parameter.cs;
        # Generated/${swig_config}/ParameterCloningMethod.cs;
        # Generated/${swig_config}/ParameterVector.cs;
        # Generated/${swig_config}/PoolingType.cs;
        # Generated/${swig_config}/ProgressWriter.cs;
        # Generated/${swig_config}/ProgressWriterVector.cs;
        # Generated/${swig_config}/SizeTVector.cs;
        # Generated/${swig_config}/SizeTVectorVector.cs;
        # Generated/${swig_config}/StorageFormat.cs;
        # Generated/${swig_config}/StreamConfiguration.cs;
        # Generated/${swig_config}/StreamConfigurationVector.cs;
        # Generated/${swig_config}/StreamInformation.cs;
        # Generated/${swig_config}/StringVector.cs;
        # Generated/${swig_config}/SWIGTYPE_p_int8_t.cs;
        # Generated/${swig_config}/SWIGTYPE_p_void.cs;
        # Generated/${swig_config}/TraceLevel.cs;
        # Generated/${swig_config}/Trainer.cs;
        # Generated/${swig_config}/TrainingParameterScheduleDouble.cs;
        # Generated/${swig_config}/UnorderedMapParameterNDArrayViewPtr.cs;
        # Generated/${swig_config}/UnorderedMapStreamInformationMinibatchData.cs;
        # Generated/${swig_config}/UnorderedMapStreamInformationPairNDArrayViewPtrNDArrayViewPtr.cs;
        # Generated/${swig_config}/UnorderedMapStringDictionaryValue.cs;
        # Generated/${swig_config}/UnorderedMapVariableMinibatchData.cs;
        # Generated/${swig_config}/UnorderedMapVariableValuePtr.cs;
        # Generated/${swig_config}/UnorderedMapVariableVariable.cs;
        # Generated/${swig_config}/UnsignedCharVector.cs;
        # Generated/${swig_config}/Value.cs;
        # Generated/${swig_config}/Variable.cs;
        # Generated/${swig_config}/VariableKind.cs;
        # Generated/${swig_config}/VariablePair.cs;
        # Generated/${swig_config}/VariablePairVector.cs;
        # Generated/${swig_config}/VariableVector.cs;
        # Generated/${swig_config}/VectorPairSizeTDouble.cs;
)

set(swig_generated_files
        ${native_swig_generated_files}
        ${csharp_swig_generated_files}
)

if(MSVC)
    set(swig_params 
            -D_MSC_VER 
            -Werror
    )
else()
    set(swig_params "")
endif()

# Create the swig command line; it needs to be constructed manually as cmake won't convert path separators for the command.
set(swig_command_line 
        ${swig_params}
        -c++ 
        -csharp 
        -namespace CNTK 
        -dllimport 
        \"${binary_name}.dll\"
)

file(TO_NATIVE_PATH "${CMAKE_CURRENT_BINARY_DIR}/Generated/" swig_outdir)
set(swig_command_line
        ${swig_command_line}
        -outdir
        \"${swig_outdir}${swig_config}\"
)

foreach(swig_include ${CMAKE_CURRENT_SOURCE_DIR}/../../../Source/CNTKv2LibraryDll/API;${CMAKE_CURRENT_SOURCE_DIR}/../../common)
    file(TO_NATIVE_PATH "${swig_include}" swig_include)
    set(swig_command_line
            ${swig_command_line}
            \"-I${swig_include}\"
    )
endforeach()

file(TO_NATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cntk_cs.i" swig_input)
set(swig_command_line
        ${swig_command_line}
        \"${swig_input}\"
)

# Invoke the command line
add_custom_command(
    COMMENT
        "Generating SWIG Proxies for C++ and C#"
    
    DEPENDS
        cntk_cs.i
        std_unordered_map.i
        ${CMAKE_CURRENT_SOURCE_DIR}/../../common/CNTKExceptionHandling.i
        ${CMAKE_CURRENT_SOURCE_DIR}/../../common/CNTKManagedCommon.i
        ${CMAKE_CURRENT_SOURCE_DIR}/../../common/CNTKValueExtend.i
        ${CMAKE_CURRENT_SOURCE_DIR}/../../common/CNTKWarnFilters.i
    OUTPUT 
        ${swig_generated_files}
    
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/Generated/${swig_config}"
    COMMAND ${swig_binary} ${swig_command_line}
    COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/cntk_cs_wrap.h" "${CMAKE_CURRENT_BINARY_DIR}/Generated"
    COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/cntk_cs_wrap.cxx" "${CMAKE_CURRENT_BINARY_DIR}/Generated"
    COMMAND ${CMAKE_COMMAND} -E remove -f "${CMAKE_CURRENT_SOURCE_DIR}/cntk_cs_wrap.h"
    COMMAND ${CMAKE_COMMAND} -E remove -f "${CMAKE_CURRENT_SOURCE_DIR}/cntk_cs_wrap.cxx"
)

# ----------------------------------------------------------------------
# |  CS Bindings
add_library(CSharpBindings SHARED ${native_swig_generated_files})

set_target_properties(CSharpBindings PROPERTIES OUTPUT_NAME ${binary_name})
set_target_properties(CSharpBindings PROPERTIES PREFIX "")

target_include_directories(CSharpBindings
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../Source/CNTKv2LibraryDll/API
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../Source/Common/Include
)

string(TOLOWER "${config}" lower_config)
message(STATUS "BugBug********************* ${config} ${lower_config}")
    
target_link_libraries(CSharpBindings
    # TODO: Eventually, we should bind the this library rather than hard-coding the value
    # BugBug PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../x64/$<CONFIG>/Cntk.Core${binary_name_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX} 
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../build/${lower_config}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Cntk.Core${binary_name_suffix}${CMAKE_SHARED_LIBRARY_SUFFIX}
)
