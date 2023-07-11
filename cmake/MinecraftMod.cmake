set(CMAKE_ASM_NASM_OBJECT_FORMAT win64)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CONFIGURATION_TYPES "Release;RelWithDebInfo")

set(SYM_PLATFORM windows)
set(SYM_ARCH x64)

if (NOT DEFINED ZENOVA_DIR)
	set(ZENOVA_DIR $ENV{ZENOVA_DATA})
endif()

set(ZENOVA_DEV_DIR "${ZENOVA_DIR}/dev")

macro(setup_mod)
	set(options API)
	set(singleArgs 
		NAME
		SRC_DIR
		INCL_DIR
		GEN_DIR
		MAPS_DIR)
	set(multiArgs GAME_VER)
	cmake_parse_arguments(MOD "${options}" "${singleArgs}" "${multiArgs}" ${ARGN})

	set(SYMMAPS_DIR "${MOD_MAPS_DIR}/${SYM_PLATFORM}-${SYM_ARCH}")
	
	if (NOT MOD_API)
		set(MOD_OUT_DIR "${ZENOVA_DIR}/mods/${MOD_NAME}")
	endif()

	if(NOT EXISTS ${MOD_GEN_DIR})
		file(MAKE_DIRECTORY ${MOD_GEN_DIR})
		file(TOUCH "${MOD_GEN_DIR}/initasm.asm")
		file(TOUCH "${MOD_GEN_DIR}/initcpp.cpp")
		file(TOUCH "${MOD_GEN_DIR}/initcpp.h")
	endif()

	file(GLOB_RECURSE INCLUDE_LIST
		"${MOD_INCL_DIR}/*.hpp"
		"${MOD_INCL_DIR}/*.h"
	)

	file(GLOB_RECURSE SRC_INCLUDE_LIST
		"${MOD_SRC_DIR}/*.hpp"
		"${MOD_SRC_DIR}/*.h"
	)

	file(GLOB_RECURSE INC_SOURCE_LIST
		"${MOD_INCL_DIR}/*.cpp"
		"${MOD_INCL_DIR}/*.cxx"
		"${MOD_INCL_DIR}/*.cc"
		"${MOD_INCL_DIR}/*.asm"
	)

	file(GLOB_RECURSE SOURCE_LIST
		"${MOD_SRC_DIR}/*.cpp"
		"${MOD_SRC_DIR}/*.cxx"
		"${MOD_SRC_DIR}/*.cc"
		"${MOD_SRC_DIR}/*.asm"
	)

	file(GLOB_RECURSE SYMMAPS
		"${MOD_MAPS_DIR}/*.json"
	)

	add_library(${MOD_NAME} SHARED
		${SRC_INCLUDE_LIST}
		${INCLUDE_LIST}
		${INC_SOURCE_LIST}
		${SOURCE_LIST}
		${SYMMAPS}
	)

	if (NOT MOD_API)
		set_target_properties(${MOD_NAME} PROPERTIES
			RUNTIME_OUTPUT_DIRECTORY "$<1:${MOD_OUT_DIR}>"
			LIBRARY_OUTPUT_DIRECTORY "$<1:${MOD_OUT_DIR}>"
			ARCHIVE_OUTPUT_DIRECTORY "$<1:${MOD_OUT_DIR}>"
		)
	endif()

	target_include_directories(${MOD_NAME} PRIVATE
		"${ZENOVA_DEV_DIR}/inc"
		"${MOD_INCL_DIR}"
		"${MOD_SRC_DIR}"
	)

	target_link_libraries(${MOD_NAME} 
		${ZENOVA_DEV_DIR}/lib/ZenovaAPI.lib
	)

	if (NOT MOD_API)
		target_link_libraries(${MOD_NAME} 
			${ZENOVA_DEV_DIR}/lib/BedrockAPI.lib
		)
	endif()

	list(POP_FRONT MOD_GAME_VER GAME_MAJOR GAME_MINOR GAME_PATCH GAME_REVISION)

	target_compile_definitions(${MOD_NAME} 
		PUBLIC GAME_MAJOR=${GAME_MAJOR}
		PUBLIC GAME_MINOR=${GAME_MINOR}
		PUBLIC GAME_PATCH=${GAME_PATCH}
		PUBLIC GAME_REVISION=${GAME_REVISION}
	)

	set(GAME_VER_STR "${GAME_MAJOR}.${GAME_MINOR}.${GAME_PATCH}.${GAME_REVISION}")

	if (MSVC)
		if (MOD_RES_DIR)
			add_custom_command(TARGET ${MOD_NAME}
				POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_directory
				${MOD_RES_DIR} ${MOD_OUT_DIR}
				COMMENT "Resources copied to ${MOD_OUT_DIR}"
			)
		endif()

		# todo: change to support other arch builds for the current platform
		add_custom_command(
			OUTPUT "${MOD_GEN_DIR}/initcpp.cpp" "${MOD_GEN_DIR}/initasm.asm" "${MOD_GEN_DIR}/initcpp.h"
			COMMAND py -3 ${ZENOVA_DEV_DIR}/tools/process_symbol_map.py -e -a ${SYM_ARCH} -p ${SYM_PLATFORM} -d ${MOD_GEN_DIR} ${SYMMAPS_DIR}/*.json
			DEPENDS ${ZENOVA_DEV_DIR}/tools/process_symbol_map.py ${SYMMAPS_DIR}/*.json
		)

		source_group(TREE ${MOD_MAPS_DIR} PREFIX "Symbol Maps//" FILES ${SYMMAPS})
		source_group(TREE ${MOD_INCL_DIR} PREFIX "Header Files//" FILES ${INCLUDE_LIST})
		source_group(TREE ${MOD_SRC_DIR} PREFIX "Header Files//" FILES ${SRC_INCLUDE_LIST})
		source_group(TREE ${MOD_INCL_DIR} PREFIX "Source Files//" FILES ${INC_SOURCE_LIST})
		source_group(TREE ${MOD_SRC_DIR} PREFIX "Source Files//" FILES ${SOURCE_LIST})
		
		add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
		add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
	endif()
endmacro()
