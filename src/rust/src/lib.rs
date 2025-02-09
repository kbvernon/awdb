use extendr_api::prelude::*;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{collections::HashMap, sync::OnceLock};

// https://wcc.sc.egov.usda.gov/awdbRestApi/swagger-ui/index.html

// STATION DATA ----------------------------------------------------------------
// each station dataset is a row in the data frame
// want to move StationElement variables up to this top level,
// and let Values be a list column with a data frame in each row
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationDataSet(Vec<StationData>);

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationData {
    pub station_triplet: String,
    pub data: Vec<ElementData>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ElementData {
    pub station_element: StationElement,
    pub values: Vec<Values>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
pub struct StationElement {
    pub element_code: String,
    pub ordinal: i32,
    pub height_depth: Option<i32>,
    pub duration_name: String,
    pub data_precision: i32,
    pub stored_unit_code: String,
    pub original_unit_code: String,
    pub begin_date: String,
    pub end_date: String,
    pub derived_data: bool,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
pub struct Values {
    pub date: Option<String>,
    pub month: Option<i32>,
    pub month_part: Option<String>,
    pub year: Option<i32>,
    pub collection_date: Option<String>,
    pub value: Option<f64>,
    pub qc_flag: Option<String>,
    pub qa_flag: Option<String>,
    pub orig_value: Option<f64>,
    pub orig_qc_flag: Option<String>,
    pub average: Option<f64>,
    pub median: Option<i32>,
}

impl From<StationDataSet> for Robj {
    fn from(sd: StationDataSet) -> Self {
        let n_row = sd.0.iter().map(|x| x.data.len()).sum();

        let mut station_triplet: Vec<String> = Vec::with_capacity(n_row);
        let mut element_code: Vec<String> = Vec::with_capacity(n_row);
        let mut ordinal: Vec<i32> = Vec::with_capacity(n_row);
        let mut height_depth: Vec<Option<i32>> = Vec::with_capacity(n_row);
        let mut duration_name: Vec<String> = Vec::with_capacity(n_row);
        let mut data_precision: Vec<i32> = Vec::with_capacity(n_row);
        let mut stored_unit_code: Vec<String> = Vec::with_capacity(n_row);
        let mut original_unit_code: Vec<String> = Vec::with_capacity(n_row);
        let mut begin_date: Vec<String> = Vec::with_capacity(n_row);
        let mut end_date: Vec<String> = Vec::with_capacity(n_row);
        let mut derived_data: Vec<bool> = Vec::with_capacity(n_row);
        let mut values: List = List::new(n_row);

        values.set_class(&["AsIs"]).unwrap();

        for (i, x) in sd.0.into_iter().enumerate() {
            for y in x.data.into_iter() {
                let StationElement {
                    element_code: ec,
                    ordinal: o,
                    height_depth: hd,
                    duration_name: dn,
                    data_precision: dp,
                    stored_unit_code: suc,
                    original_unit_code: ouc,
                    begin_date: bd,
                    end_date: ed,
                    derived_data: dd,
                } = y.station_element;

                station_triplet.push(x.station_triplet.clone());
                element_code.push(ec);
                ordinal.push(o);
                height_depth.push(hd);
                duration_name.push(dn);
                data_precision.push(dp);
                stored_unit_code.push(suc);
                original_unit_code.push(ouc);
                begin_date.push(bd);
                end_date.push(ed);
                derived_data.push(dd);

                let values_df = y.values.into_dataframe().unwrap().into_robj();
                values.set_elt(i, values_df).unwrap();
            }
        }

        let mut df = data_frame!(
            station_triplet = station_triplet,
            element_code = element_code,
            ordinal = ordinal,
            height_depth = height_depth,
            duration_name = duration_name,
            data_precision = data_precision,
            stored_unit_code = stored_unit_code,
            original_unit_code = original_unit_code,
            begin_date = begin_date,
            end_date = end_date,
            derived_data = derived_data,
            element_values = values
        );

        df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();

        df
    }
}

#[extendr]
fn parse_station_dataset_json(x: Strings) -> Robj {
    let vec_data = x
        .into_iter()
        .flat_map(|v| serde_json::from_str::<StationDataSet>(v).unwrap().0)
        .collect();

    StationDataSet(vec_data).into()
}

// STATION FORECAST ------------------------------------------------------------
// each station forecast set is a row in the data frame
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationForecastSet(Vec<StationForecast>);

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationForecast {
    pub station_triplet: String,
    pub forecast_point_name: String,
    pub data: Vec<Forecast>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Forecast {
    pub element_code: String,
    pub forecast_period: Vec<String>,
    pub forecast_status: String,
    pub issue_date: String,
    pub period_normal: f64,
    pub publication_date: String,
    pub unit_code: String,
    pub forecast_values: HashMap<String, Value>,
}

impl From<StationForecastSet> for Robj {
    fn from(sf: StationForecastSet) -> Self {
        let n_row = sf.0.len();

        let mut station_triplet: Vec<String> = Vec::with_capacity(n_row);
        let mut forecast_point_name: Vec<String> = Vec::with_capacity(n_row);
        let mut element_code: Vec<String> = Vec::with_capacity(n_row);
        let mut forecast_period: List = List::new(n_row);
        let mut forecast_status: Vec<String> = Vec::with_capacity(n_row);
        let mut issue_date: Vec<String> = Vec::with_capacity(n_row);
        let mut period_normal: Vec<f64> = Vec::with_capacity(n_row);
        let mut publication_date: Vec<String> = Vec::with_capacity(n_row);
        let mut unit_code: Vec<String> = Vec::with_capacity(n_row);
        let mut forecast_values: List = List::new(n_row);

        forecast_period.set_class(&["AsIs"]).unwrap();
        forecast_values.set_class(&["AsIs"]).unwrap();

        for (i, x) in sf.0.into_iter().enumerate() {
            for y in x.data.into_iter() {
                station_triplet.push(x.station_triplet.clone());
                forecast_point_name.push(x.forecast_point_name.clone());
                element_code.push(y.element_code);

                forecast_period
                    .set_elt(i, y.forecast_period.into())
                    .unwrap();

                forecast_status.push(y.forecast_status);
                issue_date.push(y.issue_date);
                period_normal.push(y.period_normal);
                publication_date.push(y.publication_date);
                unit_code.push(y.unit_code);

                let keys: Strings = y.forecast_values.keys().cloned().collect();
                let values: Vec<f64> = y
                    .forecast_values
                    .values()
                    .map(|v| v.as_f64().unwrap())
                    .collect();
                let mut df = data_frame!(keys = keys, values = values);
                df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();
                forecast_values.set_elt(i, df).unwrap();
            }
        }

        let mut df = data_frame!(
            station_triplet = station_triplet,
            forecast_point_name = forecast_point_name,
            element_code = element_code,
            forecast_period = forecast_period,
            forecast_status = forecast_status,
            issue_date = issue_date,
            period_normal = period_normal,
            publication_date = publication_date,
            unit_code = unit_code,
            forecast_values = forecast_values
        );

        df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();

        df
    }
}

#[extendr]
fn parse_station_forecast_set_json(x: Strings) -> Robj {
    let vec_data = x
        .into_iter()
        .flat_map(|v| serde_json::from_str::<StationForecastSet>(v).unwrap().0)
        .collect();

    StationForecastSet(vec_data).into()
}

// STATION METADATA ------------------------------------------------------------
// each station metadataset is a row in the data frame
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationMetadataSet(Vec<StationMetadata>);

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationMetadata {
    pub station_triplet: String,
    pub station_id: String,
    pub state_code: String,
    pub network_code: String,
    pub name: Option<String>,
    pub dco_code: Option<String>,
    pub county_name: Option<String>,
    pub huc: Option<String>,
    pub elevation: Option<f64>,
    pub latitude: f64,
    pub longitude: f64,
    pub data_time_zone: Option<f64>,
    pub pedon_code: Option<String>,
    pub shef_id: Option<String>,
    pub begin_date: Option<String>,
    pub end_date: Option<String>,
    pub forecast_point: Option<ForecastPoint>,
    pub reservoir_metadata: Option<ReservoirMetadata>,
    pub station_elements: Option<Vec<StationElement>>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ForecastPoint {
    pub name: String,
    pub forecaster: String,
    pub exceedence_probabilities: Vec<i32>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ReservoirMetadata {
    pub capacity: i32,
    pub elevation_at_capacity: i32,
    pub usable_capacity: i32,
}

impl From<StationMetadataSet> for Robj {
    fn from(sm: StationMetadataSet) -> Self {
        let n_row = sm.0.len();

        let mut station_triplet: Vec<String> = Vec::with_capacity(n_row);
        let mut station_id: Vec<String> = Vec::with_capacity(n_row);
        let mut state_code: Vec<String> = Vec::with_capacity(n_row);
        let mut network_code: Vec<String> = Vec::with_capacity(n_row);
        let mut name: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut dco_code: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut county_name: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut huc: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut elevation: Vec<Option<f64>> = Vec::with_capacity(n_row);
        let mut latitude: Vec<f64> = Vec::with_capacity(n_row);
        let mut longitude: Vec<f64> = Vec::with_capacity(n_row);
        let mut data_time_zone: Vec<Option<f64>> = Vec::with_capacity(n_row);
        let mut pedon_code: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut shef_id: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut begin_date: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut end_date: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut station_elements: List = List::new(n_row);
        let mut station_forecasts: List = List::new(n_row);
        let mut station_reservoir: List = List::new(n_row);

        station_elements.set_class(&["AsIs"]).unwrap();
        station_forecasts.set_class(&["AsIs"]).unwrap();
        station_reservoir.set_class(&["AsIs"]).unwrap();

        for (i, x) in sm.0.into_iter().enumerate() {
            station_triplet.push(x.station_triplet);
            station_id.push(x.station_id);
            state_code.push(x.state_code);
            network_code.push(x.network_code);
            name.push(x.name);
            dco_code.push(x.dco_code);
            county_name.push(x.county_name);
            huc.push(x.huc);
            elevation.push(x.elevation);
            latitude.push(x.latitude);
            longitude.push(x.longitude);
            data_time_zone.push(x.data_time_zone);
            pedon_code.push(x.pedon_code);
            shef_id.push(x.shef_id);
            begin_date.push(x.begin_date);
            end_date.push(x.end_date);

            if let Some(e) = x.station_elements {
                let mut elements_df = e.into_dataframe().unwrap().into_robj();
                elements_df
                    .set_class(&["tbl_df", "tbl", "data.frame"])
                    .unwrap();
                station_elements.set_elt(i, elements_df).unwrap();
            }

            if let Some(e) = x.forecast_point {
                let mut ep = list!(e.exceedence_probabilities);
                ep.set_class(&["AsIs"]).unwrap();

                let mut forecast_df = data_frame!(
                    name = e.name,
                    forecaster = e.forecaster,
                    exceedence_probabilities = ep
                );

                forecast_df
                    .set_class(&["tbl_df", "tbl", "data.frame"])
                    .unwrap();
                station_forecasts.set_elt(i, forecast_df).unwrap();
            }

            if let Some(e) = x.reservoir_metadata {
                let mut reservoir_df = data_frame!(
                    capacity = e.capacity,
                    elevation_at_capacity = e.elevation_at_capacity,
                    usable_capacity = e.usable_capacity
                );
                reservoir_df
                    .set_class(&["tbl_df", "tbl", "data.frame"])
                    .unwrap();
                station_reservoir.set_elt(i, reservoir_df).unwrap();
            }
        }

        let mut df = data_frame!(
            station_triplet = station_triplet,
            station_id = station_id,
            state_code = state_code,
            network_code = network_code,
            name = name,
            dco_code = dco_code,
            county_name = county_name,
            huc = huc,
            elevation = elevation,
            latitude = latitude,
            longitude = longitude,
            data_time_zone = data_time_zone,
            pedon_code = pedon_code,
            shef_id = shef_id,
            begin_date = begin_date,
            end_date = end_date,
            forecast_metadata = station_forecasts,
            reservoir_metadata = station_reservoir,
            element_metadata = station_elements
        );

        df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();

        df
    }
}

#[extendr]
fn parse_station_metadataset_json(x: Strings) -> Robj {
    let vec_metadata = x
        .into_iter()
        .flat_map(|v| serde_json::from_str::<StationMetadataSet>(v).unwrap().0)
        .collect();

    StationMetadataSet(vec_metadata).into()
}

// TODO: parse json from references endpoint

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod awdb;
    fn parse_station_dataset_json;
    fn parse_station_forecast_set_json;
    fn parse_station_metadataset_json;
}
