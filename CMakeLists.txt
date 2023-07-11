cmake_minimum_required(VERSION 3.12)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/)

include(MinecraftMod)
project(BedrockAPI CXX ASM_NASM)

setup_mod(API 
	NAME "BedrockAPI"
	SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src"
	INCL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/inc"
	GEN_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/generated"
	MAPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/maps"
	GAME_VER 1 14 60 5
)

target_compile_definitions(${MOD_NAME} PUBLIC BEDROCK_API)

if (MSVC)
	set_target_properties(${MOD_NAME} PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY "$<1:${ZENOVA_DIR}/versions/Minecraft-${GAME_VER_STR}>"
		LIBRARY_OUTPUT_DIRECTORY "$<1:${ZENOVA_DIR}/versions/Minecraft-${GAME_VER_STR}>"
		ARCHIVE_OUTPUT_DIRECTORY "$<1:${ZENOVA_DEV_DIR}/lib>"
	)

	add_custom_command(TARGET ${MOD_NAME}
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_directory
		${CMAKE_CURRENT_SOURCE_DIR}/inc
		${ZENOVA_DEV_DIR}/inc
		COMMENT "Headers copied to ${ZENOVA_DIR}/dev/inc"
	)
endif()

get_cmake_property(_variableNames VARIABLES)
list (SORT _variableNames)
foreach (_variableName ${_variableNames})
	message(STATUS "${_variableName}=${${_variableName}}")
endforeach()
