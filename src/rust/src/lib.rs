use extendr_api::prelude::*;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::BTreeMap;

// https://wcc.sc.egov.usda.gov/awdbRestApi/swagger-ui/index.html

// STATION DATA ----------------------------------------------------------------
// each station dataset is a row in the data frame
// want to move StationElement variables up to this top level,
// and let Values be a list column with a data frame in each row
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct StationDataSet(Vec<StationData>);

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct StationData {
    station_triplet: String,
    data: Vec<ElementData>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct ElementData {
    station_element: StationElement,
    values: Vec<Values>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct StationElement {
    element_code: String,
    ordinal: i32,
    height_depth: Option<i32>,
    duration_name: String,
    data_precision: i32,
    stored_unit_code: String,
    original_unit_code: String,
    begin_date: String,
    end_date: String,
    derived_data: bool,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct Values {
    date: Option<String>,
    month: Option<i32>,
    month_part: Option<String>,
    year: Option<i32>,
    collection_date: Option<String>,
    value: Option<f64>,
    qc_flag: Option<String>,
    qa_flag: Option<String>,
    orig_value: Option<f64>,
    orig_qc_flag: Option<String>,
    average: Option<f64>,
    median: Option<i32>,
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
        let mut values: Vec<Robj> = Vec::with_capacity(n_row);

        for x in sd.0.into_iter() {
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

                let mut values_df = y.values.into_dataframe().unwrap().into_robj();
                values_df
                    .set_class(&["tbl_df", "tbl", "data.frame"])
                    .unwrap();

                values.push(drop_empty_columns(&values_df).unwrap());
            }
        }

        let mut values = List::from_values(values);
        values.set_class(&["AsIs"]).unwrap();

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

        drop_empty_columns(&df).unwrap()
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
struct StationForecastSet(Vec<StationForecast>);

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct StationForecast {
    station_triplet: String,
    forecast_point_name: String,
    data: Vec<Forecast>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct Forecast {
    element_code: String,
    forecast_period: Vec<String>,
    forecast_status: String,
    issue_date: String,
    period_normal: Option<f64>,
    publication_date: String,
    unit_code: String,
    forecast_values: BTreeMap<String, Value>,
}

impl From<StationForecastSet> for Robj {
    fn from(sf: StationForecastSet) -> Self {
        let n_row = sf.0.len();

        let mut station_triplet: Vec<String> = Vec::with_capacity(n_row);
        let mut forecast_point_name: Vec<String> = Vec::with_capacity(n_row);
        let mut element_code: Vec<String> = Vec::with_capacity(n_row);
        let mut forecast_period: Vec<String> = Vec::with_capacity(n_row);
        let mut forecast_status: Vec<String> = Vec::with_capacity(n_row);
        let mut issue_date: Vec<String> = Vec::with_capacity(n_row);
        let mut period_normal: Vec<Option<f64>> = Vec::with_capacity(n_row);
        let mut publication_date: Vec<String> = Vec::with_capacity(n_row);
        let mut unit_code: Vec<String> = Vec::with_capacity(n_row);
        let mut forecast_values: Vec<Robj> = Vec::with_capacity(n_row);

        for x in sf.0.into_iter() {
            for y in x.data.into_iter() {
                station_triplet.push(x.station_triplet.clone());
                forecast_point_name.push(x.forecast_point_name.clone());
                element_code.push(y.element_code);
                forecast_period.push(y.forecast_period.join(":"));
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
                let mut df = data_frame!(probability = keys, value = values);
                df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();
                forecast_values.push(drop_empty_columns(&df).unwrap());
            }
        }

        let mut forecast_values = List::from_values(forecast_values);

        forecast_values.set_class(&["AsIs"]).unwrap();

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

        drop_empty_columns(&df).unwrap()
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

// REFERENCES ------------------------------------------------------------------
// only parse one reference list at a time
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct DcoDto {
    dcos: Vec<DcoRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct DcoRef {
    code: String,
    name: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct DurationDto {
    durations: Vec<DurationRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct DurationRef {
    code: String,
    name: String,
    duration_minutes: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct ElementDto {
    elements: Vec<ElementRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct ElementRef {
    code: String,
    name: String,
    physical_element_name: String,
    function_code: String,
    data_precision: i32,
    description: Option<String>,
    stored_unit_code: String,
    english_unit_code: String,
    metric_unit_code: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct ForecastDto {
    forecast_periods: Vec<ForecastRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct ForecastRef {
    code: String,
    name: String,
    description: Option<String>,
    begin_month_day: Option<String>,
    end_month_day: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct FunctionDto {
    functions: Vec<FunctionRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct FunctionRef {
    code: String,
    abbreviation: String,
    name: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct InstrumentDto {
    instruments: Vec<InstrumentRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct InstrumentRef {
    name: String,
    transducer_length: i32,
    data_precision_adjustment: i32,
    manufacturer: String,
    model: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct NetworkDto {
    networks: Vec<NetworkRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct NetworkRef {
    code: String,
    name: String,
    description: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct PhysicalElementDto {
    physical_elements: Vec<PhysicalElementRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct PhysicalElementRef {
    name: String,
    shef_physical_element_code: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct StateDto {
    states: Vec<StateRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct StateRef {
    code: String,
    fips_number: String,
    name: String,
    country_code: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct UnitDto {
    units: Vec<UnitRef>,
}

#[derive(Serialize, Deserialize, Debug, Clone, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
struct UnitRef {
    code: String,
    singular_name: String,
    plural_name: Option<String>,
    description: Option<String>,
}

#[extendr]
fn parse_station_reference_json(x: Strings, reference_type: Strings) -> Robj {
    let json = x[0].as_str();
    let rtype = reference_type[0].as_str();

    let mut df = match rtype {
        "dcos" => {
            let dco = serde_json::from_str::<DcoDto>(json).unwrap();
            dco.dcos.into_dataframe().into_robj()
        }
        "durations" => {
            let duration = serde_json::from_str::<DurationDto>(json).unwrap();
            duration.durations.into_dataframe().into_robj()
        }
        "elements" => {
            let element = serde_json::from_str::<ElementDto>(json).unwrap();
            element.elements.into_dataframe().into_robj()
        }
        "forecastPeriods" => {
            let forecast = serde_json::from_str::<ForecastDto>(json).unwrap();
            forecast.forecast_periods.into_dataframe().into_robj()
        }
        "functions" => {
            let function = serde_json::from_str::<FunctionDto>(json).unwrap();
            function.functions.into_dataframe().into_robj()
        }
        "instruments" => {
            let instrument = serde_json::from_str::<InstrumentDto>(json).unwrap();
            instrument.instruments.into_dataframe().into_robj()
        }
        "networks" => {
            let network = serde_json::from_str::<NetworkDto>(json).unwrap();
            network.networks.into_dataframe().into_robj()
        }
        "physicalElements" => {
            let phys_el = serde_json::from_str::<PhysicalElementDto>(json).unwrap();
            phys_el.physical_elements.into_dataframe().into_robj()
        }
        "states" => {
            let state = serde_json::from_str::<StateDto>(json).unwrap();
            state.states.into_dataframe().into_robj()
        }
        "units" => {
            let unit = serde_json::from_str::<UnitDto>(json).unwrap();
            unit.units.into_dataframe().into_robj()
        }
        _ => data_frame!(),
    };

    df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();

    drop_empty_columns(&df).unwrap()
}

// STATION METADATA ------------------------------------------------------------
// each station metadataset is a row in the data frame
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct StationMetadataSet(Vec<StationMetadata>);

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct StationMetadata {
    station_triplet: String,
    station_id: String,
    state_code: String,
    network_code: String,
    name: Option<String>,
    dco_code: Option<String>,
    county_name: Option<String>,
    huc: Option<String>,
    elevation: Option<f64>,
    latitude: f64,
    longitude: f64,
    data_time_zone: Option<f64>,
    pedon_code: Option<String>,
    shef_id: Option<String>,
    begin_date: Option<String>,
    end_date: Option<String>,
    forecast_point: Option<ForecastPoint>,
    reservoir_metadata: Option<ReservoirMetadata>,
    station_elements: Option<Vec<StationElement>>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct ForecastPoint {
    name: String,
    forecaster: String,
    exceedence_probabilities: Vec<i32>,
}

impl From<ForecastPoint> for Robj {
    fn from(x: ForecastPoint) -> Self {
        let mut ep = list!(x.exceedence_probabilities);
        ep.set_class(&["AsIs"]).unwrap();

        let mut df = data_frame!(
            name = x.name,
            forecaster = x.forecaster,
            exceedence_probabilities = ep
        );

        df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();

        drop_empty_columns(&df).unwrap()
    }
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
struct ReservoirMetadata {
    capacity: i32,
    elevation_at_capacity: i32,
    usable_capacity: i32,
}

impl From<ReservoirMetadata> for Robj {
    fn from(x: ReservoirMetadata) -> Self {
        let mut df = data_frame!(
            capacity = x.capacity,
            elevation_at_capacity = x.elevation_at_capacity,
            usable_capacity = x.usable_capacity
        );

        df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();

        drop_empty_columns(&df).unwrap()
    }
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
        let mut station_forecasts = List::new(n_row);
        let mut station_reservoir = List::new(n_row);
        let mut station_elements = List::new(n_row);

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

                station_elements
                    .set_elt(i, drop_empty_columns(&elements_df).unwrap())
                    .unwrap();
            }

            if let Some(e) = x.forecast_point {
                station_forecasts.set_elt(i, e.into()).unwrap();
            }

            if let Some(e) = x.reservoir_metadata {
                station_reservoir.set_elt(i, e.into()).unwrap();
            }
        }

        station_forecasts.set_class(&["AsIs"]).unwrap();
        station_reservoir.set_class(&["AsIs"]).unwrap();
        station_elements.set_class(&["AsIs"]).unwrap();

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

        drop_empty_columns(&df).unwrap()
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

// helper to clean tables when they have empty columns
fn drop_empty_columns(x: &Robj) -> Result<Robj> {
    // converting to a list because DataFrame doesn't have attributes
    // TODO: make a github issue....
    let lst = List::try_from(x)?;

    // We can safely unwrap because we know there is a names attribute
    let mut to_keep = Vec::new();

    let col_names = lst.names().unwrap();

    // determine which columns to keep
    for col_name in col_names {
        let col = lst.index(col_name)?;
        match &col.rtype() {
            Rtype::Logicals => {
                for xi in Logicals::try_from(col)?.into_iter() {
                    if !xi.is_na() {
                        to_keep.push(col_name);
                        break;
                    }
                }
            }
            Rtype::Integers => {
                for xi in Integers::try_from(col)?.into_iter() {
                    if !xi.is_na() {
                        to_keep.push(col_name);
                        break;
                    }
                }
            }
            Rtype::Doubles => {
                for xi in Doubles::try_from(col)?.into_iter() {
                    if !xi.is_na() {
                        to_keep.push(col_name);
                        break;
                    }
                }
            }
            Rtype::Strings => {
                for xi in Strings::try_from(col)?.into_iter() {
                    if !xi.is_na() {
                        to_keep.push(col_name);
                        break;
                    }
                }
            }
            Rtype::List => {
                for (_, xi) in List::try_from(col)?.into_iter() {
                    if !xi.is_null() {
                        to_keep.push(col_name);
                        break;
                    }
                }
            }
            _ => (),
        }
    }
    Ok(x.slice(to_keep)?)
}

// TODO: parse json from references endpoint

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod awdb;
    fn parse_station_dataset_json;
    fn parse_station_forecast_set_json;
    fn parse_station_reference_json;
    fn parse_station_metadataset_json;
}
