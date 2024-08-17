// Copyright 2024 Cozy Auth Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use url::Url;

#[derive(Clone, Debug, serde::Deserialize)]
pub struct Settings {
    pub(crate) port: Option<u16>,
    pub(crate) relying_party_domain: Url,
    pub(crate) database_url: Option<Url>,
    pub(crate) database_schema: Option<String>,
}

impl Settings {
    pub fn from_env() -> Self {
        if cfg!(debug_assertions) {
            dotenvy::dotenv().ok();
        }
        let config = config::Config::builder()
            .add_source(config::Environment::default())
            .build()
            .expect("config must be loadable from environment");
        config
            .try_deserialize()
            .expect("config can be deserialized from enviroment")
    }

    pub(crate) fn database_url(&self) -> String {
        let mut url = self
            .database_url
            .clone()
            .expect("DATABASE_URL environment variable must be set");
        if let Some(s) = self.database_schema.clone() {
            let options = format!("--search_path={}", s);
            let mut_url = &mut url;
            let mut query = mut_url.query_pairs_mut();
            query.append_pair("options", options.as_str());
        };
        url.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use config::ConfigError;

    #[test]
    fn database_url_default() {
        let settings = Settings::from_env();
        assert_eq!(
            settings.database_url(),
            settings.database_url.unwrap().to_string()
        );
    }

    #[test]
    fn database_url_with_schema() -> Result<(), ConfigError> {
        let settings = Settings {
            database_schema: Some("cozyauth".to_string()),
            ..Settings::from_env()
        };
        assert_eq!(
            settings.database_url().as_str(),
            format!(
                "{}?options=--search_path%3Dcozyauth",
                settings.database_url.unwrap()
            )
        );
        Ok(())
    }
}
