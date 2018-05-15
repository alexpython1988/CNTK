cmake_minimum_required (VERSION 3.8)

include(../../../Tools/cmake/common.cmake REQUIRED)

EnsureProperties(CNTK_VERSION;)
EnsureTools(swig;)

# Configurations
set(CMAKE_CONFIGURATION_TYPES Debug;Release;Release_NoOpt)

set(is_debug $<CONFIG:Debug>)
set(is_release_noopt $<CONFIG:Release_NoOpt>)

include(../../../Tools/cmake/cpp_common.cmake REQUIRED)

set(binary_name_suffix -${CNTK_VERSION}$<IF:${is_debug},d,>)
set(binary_name Cntk.Core.CSBinding${binary_name_suffix})

# ----------------------------------------------------------------------
# |  SWIG
set(native_swig_generated_files
        Generated/cntk_cs_wrap.h;
        Generated/cntk_cs_wrap.cxx
)

set(csharp_swig_generated_files
        ;
        
        # cmake doesn't like lists with generator expresions used as outputs
        # Generated/$<CONFIG>/AdditionalLearningOptions.cs;
        # Generated/$<CONFIG>/Axis.cs;
        # Generated/$<CONFIG>/AxisVector.cs;
        # Generated/$<CONFIG>/BoolVector.cs;
        # Generated/$<CONFIG>/CharVector.cs;
        # Generated/$<CONFIG>/CNTKDictionary.cs;
        # Generated/$<CONFIG>/CNTKLib.cs;
        # Generated/$<CONFIG>/CNTKLibPINVOKE.cs;
        # Generated/$<CONFIG>/Constant.cs;
        # Generated/$<CONFIG>/ConstantVector.cs;
        # Generated/$<CONFIG>/DataType.cs;
        # Generated/$<CONFIG>/DataUnit.cs;
        # Generated/$<CONFIG>/DeviceDescriptor.cs;
        # Generated/$<CONFIG>/DeviceDescriptorVector.cs;
        # Generated/$<CONFIG>/DeviceKind.cs;
        # Generated/$<CONFIG>/DictionaryValue.cs;
        # Generated/$<CONFIG>/DictionaryVector.cs;
        # Generated/$<CONFIG>/DoubleVector.cs;
        # Generated/$<CONFIG>/DoubleVectorVector.cs;
        # Generated/$<CONFIG>/Evaluator.cs;
        # Generated/$<CONFIG>/float16.cs;
        # Generated/$<CONFIG>/FloatVector.cs;
        # Generated/$<CONFIG>/FloatVectorVector.cs;
        # Generated/$<CONFIG>/Function.cs;
        # Generated/$<CONFIG>/FunctionPtrVector.cs;
        # Generated/$<CONFIG>/HTKFeatureConfiguration.cs;
        # Generated/$<CONFIG>/HTKFeatureConfigurationVector.cs;
        # Generated/$<CONFIG>/IntVector.cs;
        # Generated/$<CONFIG>/Learner.cs;
        # Generated/$<CONFIG>/LearnerVector.cs;
        # Generated/$<CONFIG>/MaskKind.cs;
        # Generated/$<CONFIG>/MinibatchData.cs;
        # Generated/$<CONFIG>/MinibatchInfo.cs;
        # Generated/$<CONFIG>/MinibatchSource.cs;
        # Generated/$<CONFIG>/MinibatchSourceConfig.cs;
        # Generated/$<CONFIG>/ModelFormat.cs;
        # Generated/$<CONFIG>/NDArrayView.cs;
        # Generated/$<CONFIG>/NDArrayViewPtrVector.cs;
        # Generated/$<CONFIG>/NDMask.cs;
        # Generated/$<CONFIG>/NDShape.cs;
        # Generated/$<CONFIG>/PaddingMode.cs;
        # Generated/$<CONFIG>/PairDoubleDouble.cs;
        # Generated/$<CONFIG>/PairFloatFloat.cs;
        # Generated/$<CONFIG>/PairIntInt.cs;
        # Generated/$<CONFIG>/PairNDArrayViewPtrNDArrayViewPtr.cs;
        # Generated/$<CONFIG>/PairSizeTDouble.cs;
        # Generated/$<CONFIG>/PairSizeTInt.cs;
        # Generated/$<CONFIG>/PairSizeTSizeT.cs;
        # Generated/$<CONFIG>/Parameter.cs;
        # Generated/$<CONFIG>/ParameterCloningMethod.cs;
        # Generated/$<CONFIG>/ParameterVector.cs;
        # Generated/$<CONFIG>/PoolingType.cs;
        # Generated/$<CONFIG>/ProgressWriter.cs;
        # Generated/$<CONFIG>/ProgressWriterVector.cs;
        # Generated/$<CONFIG>/SizeTVector.cs;
        # Generated/$<CONFIG>/SizeTVectorVector.cs;
        # Generated/$<CONFIG>/StorageFormat.cs;
        # Generated/$<CONFIG>/StreamConfiguration.cs;
        # Generated/$<CONFIG>/StreamConfigurationVector.cs;
        # Generated/$<CONFIG>/StreamInformation.cs;
        # Generated/$<CONFIG>/StringVector.cs;
        # Generated/$<CONFIG>/SWIGTYPE_p_int8_t.cs;
        # Generated/$<CONFIG>/SWIGTYPE_p_void.cs;
        # Generated/$<CONFIG>/TraceLevel.cs;
        # Generated/$<CONFIG>/Trainer.cs;
        # Generated/$<CONFIG>/TrainingParameterScheduleDouble.cs;
        # Generated/$<CONFIG>/UnorderedMapParameterNDArrayViewPtr.cs;
        # Generated/$<CONFIG>/UnorderedMapStreamInformationMinibatchData.cs;
        # Generated/$<CONFIG>/UnorderedMapStreamInformationPairNDArrayViewPtrNDArrayViewPtr.cs;
        # Generated/$<CONFIG>/UnorderedMapStringDictionaryValue.cs;
        # Generated/$<CONFIG>/UnorderedMapVariableMinibatchData.cs;
        # Generated/$<CONFIG>/UnorderedMapVariableValuePtr.cs;
        # Generated/$<CONFIG>/UnorderedMapVariableVariable.cs;
        # Generated/$<CONFIG>/UnsignedCharVector.cs;
        # Generated/$<CONFIG>/Value.cs;
        # Generated/$<CONFIG>/Variable.cs;
        # Generated/$<CONFIG>/VariableKind.cs;
        # Generated/$<CONFIG>/VariablePair.cs;
        # Generated/$<CONFIG>/VariablePairVector.cs;
        # Generated/$<CONFIG>/VariableVector.cs;
        # Generated/$<CONFIG>/VectorPairSizeTDouble.cs;
)

set(swig_generated_files
        ${native_swig_generated_files};
        ${csharp_swig_generated_files}
)

if(MSVC)
    set(swig_params 
            -D_MSC_VER 
            -Werror
    )
endif()

# Create the swig command line; it needs to be constructed manually as cmake won't convert path separators for the command.
set(swig_command_line 
        "${swig_params} -c++ -csharp -namespace CNTK -dllimport \"${binary_name}.dll\""
)

file(TO_NATIVE_PATH "${CMAKE_CURRENT_BINARY_DIR}/Generated/$<CONFIG>" swig_outdir)
set(swig_command_line 
        "${swig_command_line} -outdir \"${swig_outdir}\""
)

foreach(swig_include ${CMAKE_CURRENT_SOURCE_DIR}/../../../Source/CNTKv2LibraryDll/API;${CMAKE_CURRENT_SOURCE_DIR}/../../common)
    file(TO_NATIVE_PATH "${swig_include}" swig_include)
    set(swig_command_line 
            "${swig_command_line} \"-I${swig_include}\""
    )
endforeach()

file(TO_NATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cntk_cs.i" swig_input)
set(swig_command_line 
        "${swig_command_line} \"${swig_input}\""
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
    
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/Generated/$<CONFIG>"
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

target_include_directories(CSharpBindings
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../Source/CNTKv2LibraryDll/API
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../Source/Common/Include
)

target_link_libraries(CSharpBindings
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../x64/$<CONFIG>/Cntk.Core${binary_name_suffix}${CMAKE_STATIC_LIBRARY_SUFFIX} # TODO: Eventually, we should bind the this library rather than hard-coding the value
)
