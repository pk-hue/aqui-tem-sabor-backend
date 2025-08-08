#include <iostream>
#include <crow.h>
#include <nlohmann/json.hpp>

int main() {

    crow::SimpleApp app;

    CROW_ROUTE(app, "/cardapio")
    ([]() {
        std::ifstream jsonFileStream("./settings.json");

        if(!jsonFileStream.is_open()) {
            return crow::response{
            nlohmann::json{{"error", "Json invalido."}}.dump()
            };
        }

        nlohmann::json jsonData = nlohmann::json::parse(jsonFileStream);

        crow::response response(jsonData.dump());
        response.add_header("Content-Type", "application/json");
        response.add_header("Access-Control-Allow-Origin", "*");

        return response;
    });

    CROW_ROUTE(app, "/cardapio").methods("OPTIONS"_method)
    ([] {
        crow::response res;
        res.add_header("Access-Control-Allow-Origin", "*");
        res.add_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        res.add_header("Access-Control-Allow-Headers", "Content-Type");
        return res;
    });

    CROW_ROUTE(app, "/pedido").methods(crow::HTTPMethod::POST)(
    [](const crow::request& req) {
        crow::response res;
        res.add_header("Access-Control-Allow-Origin", "*");
        res.add_header("Content-Type", "application/json");

        auto body = nlohmann::json::parse(req.body);

        if(body.empty() || !body.contains("cliente") || !body.contains("prato_id")) {
            res.code = 400;
            res.body = R"({"erro": "Campo invalido."})";
            return res;
        }

        std::string cliente = body["cliente"];
        int prato_id = body["prato_id"];

        nlohmann::json result;
        result["Status: "] = "pedido recebido com sucesso!";
        result["Cliente: "] = cliente;
        result["Numero do pedido: "] = prato_id;

        std::cout << '\n' << body.dump() << '\n';

        res = crow::response(result.dump());
        res.set_header("Content-Type", "application/json");
        return res;
    });

    CROW_ROUTE(app, "/pedido").methods("OPTIONS"_method)
    ([] {
        crow::response res;
        res.add_header("Access-Control-Allow-Origin", "*");
        res.add_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        res.add_header("Access-Control-Allow-Headers", "Content-Type");
        return res;
    });

    CROW_ROUTE(app, "/status")([]() {
        nlohmann::json res;
        res["status"] = "Rodando OK!";

        crow::response response(res.dump());
        response.add_header("Content-Type", "application/json");
        response.add_header("Access-Control-Allow-Origin", "*");
        return response;
    });

    CROW_ROUTE(app, "/status").methods("OPTIONS"_method)
    ([] {
        crow::response res;
        res.add_header("Access-Control-Allow-Origin", "*");
        res.add_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        res.add_header("Access-Control-Allow-Headers", "Content-Type");
        return res;
    });

    const char* portStr = std::getenv("PORT");
    int port = portStr ? std::stoi(portStr) : 18080;

    app.port(port).multithreaded().run();
    return 0;
};