# COVID-19 Florida Department of Health Testing Data Parser

This simple parser retrieves testing and case line (people who tested positive)
data from the Florida Department of Health's Esri/ARCGIS Feature Layers (data
sets).

## Output

This project is also a [website](https://flovid.herokuapp.com) that outputs
live aggregate metrics from the [FDOH COVID-19 Testing][1] in order to assist
data entry for [COVID Tracking Project][7] volunteers.

## Sources

### Florida Testing from Rebekah Jones at FDOH
- [Feature Layer][1]
- [Fields][2]
- [Query Interface][3]

### Florida COVID19 Case Line Data from Rebekah Jones at FDOH
- [Feature Layer][4]
- [Fields][5]
- [Query Interface][6]

## Usage

- `ruby parser.rb`

[1]: https://fdoh.maps.arcgis.com/home/item.html?id=d9de96980b574ccd933da024a0926f37
[2]: https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_Testing/FeatureServer/0
[3]: https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_Testing/FeatureServer/0/query
[4]: https://fdoh.maps.arcgis.com/home/item.html?id=f5d69a918fb747019734d9a90cd602f4
[5]: https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_COVID19_Case_Line_Data/FeatureServer/0
[6]: https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_COVID19_Case_Line_Data/FeatureServer/0/query
[7]: https://covidtracking.com
