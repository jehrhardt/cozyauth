use serde::{Deserialize, Serialize};

pub(crate) async fn handle_json_rpc_request<P, F, R>(
    request: &str,
    method: JsonRpcMethod,
    code_block: F,
) -> String
where
    P: for<'de> Deserialize<'de>,
    F: FnOnce(P) -> R,
    R: Serialize,
{
    match serde_json::from_str::<JsonRpcRequest<P>>(request) {
        Ok(JsonRpcRequest {
            method: m,
            params,
            id,
            jsonrpc,
        }) if m == method && jsonrpc.as_str() == JSON_RPC_VERSION => {
            let result = code_block(params);
            let response = JsonRpcResponse::new(result, id);
            serde_json::to_string(&response).unwrap()
        }
        _ => {
            let response = JsonRpcErrorResponse {
                code: JsonRpcErrorCode::MethodNotFound,
                message: "Method not found".to_string(),
            };
            serde_json::to_string(&response).unwrap()
        }
    }
}

const JSON_RPC_VERSION: &str = "2.0";

#[derive(PartialEq, serde::Deserialize)]
pub(crate) enum JsonRpcMethod {
    #[serde(rename = "start")]
    START,
    #[serde(rename = "finish")]
    FINISH,
}

#[derive(serde::Deserialize)]
struct JsonRpcRequest<T> {
    jsonrpc: String,
    method: JsonRpcMethod,
    params: T,
    id: u64,
}

#[derive(serde::Serialize)]
struct JsonRpcResponse<T> {
    jsonrpc: String,
    result: T,
    id: u64,
}

impl<T> JsonRpcResponse<T> {
    fn new(result: T, id: u64) -> Self {
        Self {
            jsonrpc: JSON_RPC_VERSION.to_string(),
            result,
            id,
        }
    }
}

#[derive(serde::Serialize)]
struct JsonRpcErrorResponse {
    code: JsonRpcErrorCode,
    message: String,
}

#[derive(serde::Serialize)]
enum JsonRpcErrorCode {
    MethodNotFound = -32601,
}
