use extendr_api::prelude::*;
use serde::{Deserialize, Serialize};

// https://wcc.sc.egov.usda.gov/awdbRestApi/swagger-ui/index.html

// STATION DATA ----------------------------------------------------------------
// each station dataset is a row in the data frame
// want to move StationElement variables up to this top level,
// and let Values be a list column with a data frame in each row
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationDataset(Vec<StationData>);

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

impl From<StationDataset> for Robj {
    fn from(sd: StationDataset) -> Self {
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
            values = values
        );

        df.set_class(&["tbl_df", "tbl", "data.frame"]).unwrap();

        df
    }
}

#[extendr]
fn parse_station_dataset_json(x: &str) -> Robj {
    let parsed = serde_json::from_str::<StationDataset>(x);

    match parsed {
        Ok(p) => p.into(),
        Err(_) => data_frame!(),
    }
}

// STATION METADATA ------------------------------------------------------------
// each station metadataset is a row in the data frame
#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationMetadataset(Vec<StationMetadata>);

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StationMetadata {
    pub station_triplet: String,
    pub station_id: String,
    pub state_code: String,
    pub network_code: String,
    pub name: String,
    pub dco_code: String,
    pub county_name: String,
    pub huc: String,
    pub elevation: f64,
    pub latitude: f64,
    pub longitude: f64,
    pub data_time_zone: f64,
    pub pedon_code: Option<String>,
    pub shef_id: Option<String>,
    pub begin_date: String,
    pub end_date: String,
    pub station_elements: Option<Vec<StationElement>>,
}

impl From<StationMetadataset> for Robj {
    fn from(sm: StationMetadataset) -> Self {
        let n_row = sm.0.len();

        let mut station_triplet: Vec<String> = Vec::with_capacity(n_row);
        let mut station_id: Vec<String> = Vec::with_capacity(n_row);
        let mut state_code: Vec<String> = Vec::with_capacity(n_row);
        let mut network_code: Vec<String> = Vec::with_capacity(n_row);
        let mut name: Vec<String> = Vec::with_capacity(n_row);
        let mut dco_code: Vec<String> = Vec::with_capacity(n_row);
        let mut county_name: Vec<String> = Vec::with_capacity(n_row);
        let mut huc: Vec<String> = Vec::with_capacity(n_row);
        let mut elevation: Vec<f64> = Vec::with_capacity(n_row);
        let mut data_time_zone: Vec<f64> = Vec::with_capacity(n_row);
        let mut pedon_code: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut shef_id: Vec<Option<String>> = Vec::with_capacity(n_row);
        let mut begin_date: Vec<String> = Vec::with_capacity(n_row);
        let mut end_date: Vec<String> = Vec::with_capacity(n_row);
        let mut station_elements: List = List::new(n_row);
        let mut sfc: List = List::new(n_row);

        station_elements.set_class(&["AsIs"]).unwrap();

        let mut crs = list!(
            input = "EPSG:4326",
            wkt = r#"GEOGCRS["WGS 84",
    ENSEMBLE["World Geodetic System 1984 ensemble",
        MEMBER["World Geodetic System 1984 (Transit)"],
        MEMBER["World Geodetic System 1984 (G730)"],
        MEMBER["World Geodetic System 1984 (G873)"],
        MEMBER["World Geodetic System 1984 (G1150)"],
        MEMBER["World Geodetic System 1984 (G1674)"],
        MEMBER["World Geodetic System 1984 (G1762)"],
        MEMBER["World Geodetic System 1984 (G2139)"],
        ELLIPSOID["WGS 84",6378137,298.257223563,
            LENGTHUNIT["metre",1]],
        ENSEMBLEACCURACY[2.0]],
    PRIMEM["Greenwich",0,
        ANGLEUNIT["degree",0.0174532925199433]],
    CS[ellipsoidal,2],
        AXIS["geodetic latitude (Lat)",north,
            ORDER[1],
            ANGLEUNIT["degree",0.0174532925199433]],
        AXIS["geodetic longitude (Lon)",east,
            ORDER[2],
            ANGLEUNIT["degree",0.0174532925199433]],
    USAGE[
        SCOPE["Horizontal component of 3D system."],
        AREA["World."],
        BBOX[-90,-180,90,180]],
    ID["EPSG",4326]]"#
        );

        crs.set_class(&["crs"]).unwrap();

        sfc.set_class(&["sfc_POINT", "sfc", "AsIs"])
            .unwrap()
            .set_attrib("n_empty", 0)
            .unwrap()
            .set_attrib("crs", &crs)
            .unwrap()
            .set_attrib("precision", 0)
            .unwrap();

        let mut xmin = f64::MAX;
        let mut xmax = f64::MIN;
        let mut ymin = f64::MAX;
        let mut ymax = f64::MIN;

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
            data_time_zone.push(x.data_time_zone);
            pedon_code.push(x.pedon_code);
            shef_id.push(x.shef_id);
            begin_date.push(x.begin_date);
            end_date.push(x.end_date);

            if let Some(e) = x.station_elements {
                let elements_df = e.into_dataframe().unwrap().into_robj();
                station_elements.set_elt(i, elements_df).unwrap()
            }

            if x.longitude < xmin {
                xmin = x.longitude
            }
            if x.longitude > xmax {
                xmax = x.longitude
            }
            if x.latitude < ymin {
                ymin = x.latitude
            }
            if x.latitude > ymax {
                ymax = x.latitude
            }

            let point = Doubles::from_values([x.longitude, x.latitude])
                .into_robj()
                .set_class(&["XY", "POINT", "sfg"])
                .unwrap()
                .to_owned();

            sfc.set_elt(i, point).unwrap();
        }

        let mut bbox = Doubles::from_values([xmin, ymin, xmax, ymax]);

        bbox.set_class(&["bbox"])
            .unwrap()
            .set_attrib("names", ["xmin", "ymin", "xmax", "ymax"])
            .unwrap()
            .set_attrib("crs", &crs)
            .unwrap();

        sfc.set_attrib("bbox", bbox).unwrap();

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
            data_time_zone = data_time_zone,
            pedon_code = pedon_code,
            shef_id = shef_id,
            begin_date = begin_date,
            end_date = end_date,
            station_elements = station_elements,
            geometry = sfc
        );

        df.set_class(&["sf", "tbl_df", "tbl", "data.frame"])
            .unwrap()
            .set_attrib("sf_column", "geometry")
            .unwrap();

        df
    }
}

#[extendr]
fn parse_station_metadataset_json(x: &str) -> Robj {
    let parsed = serde_json::from_str::<StationMetadataset>(x);

    match parsed {
        Ok(p) => p.into(),
        Err(_) => data_frame!(),
    }
}

// TODO
// - consider hashmap with serde_json::Value for optional json fields
// - parse json from forecast endpoint
// - parse json from metadata endpoint with forecast metadata
// - parse json from metadata endpoint with reservoir metadata
// - parse json from references endpoint

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod awdb;
    fn parse_station_dataset_json;
    fn parse_station_metadataset_json;
}
