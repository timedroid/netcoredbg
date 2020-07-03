# Fetch CoreCLR sources if necessary
if ("${CORECLR_DIR}" STREQUAL "")
    set(CORECLR_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.coreclr)

    find_package(Git REQUIRED)
    if (EXISTS "${CORECLR_DIR}/.git/config")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
            WORKING_DIRECTORY ${CORECLR_DIR})
        execute_process(
            COMMAND ${GIT_EXECUTABLE} fetch --progress --depth 1 origin "${CORECLR_BRANCH}"
            WORKING_DIRECTORY ${CORECLR_DIR}
            RESULT_VARIABLE retcode)
        if (NOT "${retcode}" STREQUAL "0")
            message(FATAL_ERROR "Fatal error when fetching ${CORECLR_BRANCH} branch")
        endif()
        execute_process(
            COMMAND ${GIT_EXECUTABLE} checkout "${CORECLR_BRANCH}"
            WORKING_DIRECTORY ${CORECLR_DIR}
            RESULT_VARIABLE retcode)
        if (NOT "${retcode}" STREQUAL "0")
            message(FATAL_ERROR "Fatal error when cheking out ${CORECLR_BRANCH} branch")
        endif()
    else()
        if (IS_DIRECTORY "${CORECLR_DIR}")
            file(REMOVE_RECURSE "${CORECLR_DIR}")
        endif()
        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone --progress --depth 1 https://github.com/dotnet/runtime "${CORECLR_DIR}" -b "${CORECLR_BRANCH}"
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE retcode)
        if (NOT "${retcode}" STREQUAL "0")
            message(FATAL_ERROR "Fatal error when cloning coreclr sources")
        endif()
    endif()
endif()

# Fetch .NET SDK binaries if necessary
if ("${DOTNET_DIR}" STREQUAL "" AND (("${DBGSHIM_RUNTIME_DIR}" STREQUAL "") OR ${BUILD_MANAGED}))
    message(FATAL_ERROR "Please specify \${DOTNET_DIR}")
endif()
