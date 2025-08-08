cmake_minimum_required(VERSION 3.31)
project(aqui_tem_sabor)

set(CMAKE_CXX_STANDARD 20)

find_package(Crow CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)

add_executable(aqui_tem_sabor src/main.cpp)

add_custom_command(
        TARGET aqui_tem_sabor POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_SOURCE_DIR}/config/settings.json
        ${CMAKE_BINARY_DIR}/settings.json
)

target_link_libraries(aqui_tem_sabor PRIVATE
        Crow::Crow
        nlohmann_json::nlohmann_json
)