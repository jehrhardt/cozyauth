use crate::helpers::TestApi;
use pavex::http::StatusCode;

#[tokio::test]
async fn health_works() {
    let api = TestApi::spawn().await;

    let response = api.get_health().await;

    assert_eq!(response.status(), StatusCode::OK);
    assert_eq!(response.text().await.ok(), Some("OK".to_string()));
}
