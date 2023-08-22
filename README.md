Sure, here's an `ABOUT.md` file that provides an overview of the project:

# Immich Web Importer

The Immich Web Importer is a Flask-based web application designed to facilitate the import and geotagging of photos into Immich. This application streamlines the process of adding geolocation information to images by allowing users to input an address and then apply the geolocation data to selected image files. It also provides a user-friendly interface for selecting directories of images to import into Immich.

**This** application is just me making a application to fit my need. It is not a part of the fantastic Immich photo application. I made it because I wanted a easy way to import my photos from my camera that does not have GPS.

## Features

- **Geolocation Integration:** Users can set geolocation information for images by inputting an address, which is then converted to latitude and longitude coordinates using the OpenStreetMap Nominatim API. The application then utilizes `exiftool` to add the geolocation data to the image metadata.
- **Uses immich cli** import tool to import the photos to Immich.

## How to Use

1. **Checkbox for Set Geolocation:** Users can choose to set geolocation information for images by checking the "Set Geolocation" checkbox. This option enables the address input field.

2. **Enter Address:** If the "Set Geolocation" checkbox is checked, users can input an address associated with the images.

3. **Select Directories:** Users can select one or more directories containing image files that they want to import into Immich.

4. **Click "Import":** Clicking the "Import" button initiates the import process. Selected images are copied to the Immich destination directory. If geolocation is set, the latitude and longitude coordinates are added to the image metadata.

5. **Map Geolocation (Optional):** If geolocation is set, users can specify the location on the map to refine the latitude and longitude coordinates.

## Getting Started

To run the Immich Web Importer locally, follow these steps:

1. Clone this repository to your local machine.

2. Install Docker or Podman.

3. Build Container:
   ```
   podman build --tag immich-geolocation-import .
   ```

4. Run the container:

```
podman run --rm --name immich-geolocation-import \
-v /input/folder:/app/source:Z \
-p 8000:8000 \
-e API_KEY=Key_from_Immich_user_interface \
-e SERVER_URL=https://url_to_your_immich.yourdomain \
-e SECRET_KEY=Randomly_generated_secret_key \
localhost/immich-geolocation-import:latest
```

Note:
* /app/source is the root directory for where you want to import subdirectories from.
* 8000 is default port
* API_KEY is from your Immich user in https://your.immich.com/user-settings -> api key
* -e SERVER_URL is the url to your immich server (without the /API part)
* -e SECRET_KEY is the secret for the flask app. Just run `pwgen 32 1` and insert it.


## Contributing

Contributions to the Immich Web Importer are welcome! Feel free to submit issues, feature requests, or pull requests to improve the application.

## License

The Immich Web Importer is open-source software released under the GPL license

---

Note: This code was huddled together in a day. Please use at your own risk.