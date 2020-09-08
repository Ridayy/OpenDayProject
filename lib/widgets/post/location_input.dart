import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:job_portal/screens/maps_screen.dart';
import 'package:location/location.dart';
import 'package:job_portal/helpers/location_helper.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;

  LocationInput(this.onSelectPlace);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;

  Future<void> _getCurrentUserLocation() {
    return Location().getLocation().then((locData) {
      // print(locData.latitude);
      // print(locData.longitude);
      final staticMapUrl = LocationHelper.generateLocationPreviewImage(
        latitude: locData.latitude,
        longitude: locData.longitude,
      );

      setState(() {
        _previewImageUrl = staticMapUrl;
      });

      widget.onSelectPlace(locData.latitude, locData.longitude);
    });
  }

  Future<void> _selectOnMap() {
    return Navigator.of(context)
        .push<LatLng>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) {
        return MapsScreen(
          isSelecting: true,
        );
      },
    ))
        .then((selectedLocation) {
      if (selectedLocation == null) {
        return;
      }
      // print("SELECTED LOCATION");
      // print(selectedLocation.latitude);
      // print(selectedLocation.longitude);
      final staticMapUrl = LocationHelper.generateLocationPreviewImage(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );

      setState(() {
        _previewImageUrl = staticMapUrl;
      });
      widget.onSelectPlace(
          selectedLocation.latitude, selectedLocation.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
          height: 170,
          child: _previewImageUrl == null
              ? new Text(
                  "No Location Chosen",
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton.icon(
              onPressed: () {
                _getCurrentUserLocation();
              },
              icon: Icon(Icons.location_on),
              label: new Text("Current Location"),
              textColor: Theme.of(context).primaryColor,
            ),
            FlatButton.icon(
              onPressed: () {
                _selectOnMap();
              },
              icon: Icon(Icons.map),
              label: new Text("Select on Map"),
              textColor: Theme.of(context).primaryColor,
            )
          ],
        ),
      ],
    );
  }
}
